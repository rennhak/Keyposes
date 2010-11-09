#include "CController.h"



#define BIT_MULTIPLIER    pow(2,GENE_LENGTH)


//----------------------------- Render ----------------------------------
//
//  renders the tiddlywink on a DC
//-----------------------------------------------------------------------
void STiddlywink::Render(HDC &surface)
{
  Ellipse(surface, x-r, y-r, x+r, y+r);
}



//------------------------------- Init -----------------------------------
//
//  initializes the controller
//------------------------------------------------------------------------
void CController::Init(int cyClient,
                       int cxClient,
                       int NumTWinks,
                       int minRad,
                       int maxRad)
{
  m_cxClient   = cxClient;
  m_cyClient   = cyClient;
  m_iNumTWinks = NumTWinks;
  m_iMinRad    = minRad;
  m_iMaxRad    = maxRad;
  m_bStarted   = false;
  m_iGeneration= 0;

  //create a number of randomly sized tiddlywinks
  for (int t=0; t<NumTWinks; ++t)
  {
    int radius = RandInt(minRad, maxRad);

    bool bOverlapped = true;

    //keep creating tiddlywinks until we find one that doesn't overlap
    //any others.
    while (bOverlapped)
    {

      STiddlywink tw(RandInt(radius, m_cxClient-radius),
                     RandInt(radius, m_cyClient-radius-30),
                     radius);

      if (!Overlapped(tw))
      {

        //its not overlapped so we can add it
        m_vecTW.push_back(tw);

        bOverlapped = false;
      }
    }

  }
  
  //inititialize the GA
  m_pGA = new Cga(CROSSOVER_RATE,
                  MUTATION_RATE,
                  POP_SIZE,
                  CHROMO_LENGTH,
                  GENE_LENGTH);

  //grab the genomes
  m_vecPop = m_pGA->GrabGenomes();
}

//----------------------------- Reset ------------------------------------
//
//  resets the sim ready for another run
//------------------------------------------------------------------------
void CController::Reset()
{
  delete m_pGA;

  //clear the tiddly winks
  m_vecTW.clear();

  //reinitialize the app. It is set to immediately resume the run with
  //the new values
  Init(m_cyClient, m_cxClient,m_iNumTWinks, m_iMinRad, m_iMaxRad);
}

//------------------------- Overlapped -----------------------------------
//
//  tests to see if a tiddlywink is overlapping any others
//------------------------------------------------------------------------
bool CController::Overlapped(const STiddlywink &tw)
{
  for (int t=0; t<m_vecTW.size(); ++t)
  {
    if (TwoCirclesOverlapped(tw.x, tw.y, tw.r,
                             m_vecTW[t].x, m_vecTW[t].y, m_vecTW[t].r))
    {
      return true;
    }
  }

  return false;
}

//------------------------------- Render --------------------------------
//
//  Renders the static tiddlywinks and the best genome found so far
//-----------------------------------------------------------------------
void CController::Render(HDC &surface)
{
  
  SelectObject(surface, GetStockObject(HOLLOW_BRUSH));

  for (int t=0; t<m_vecTW.size(); ++t)
  {
    m_vecTW[t].Render(surface);
  }
   
  if (m_iGeneration)
  {
    RenderBestGenome(surface);
  }
  
  SetBkMode(surface, TRANSPARENT);

  string s = "Generation: " + itos(m_iGeneration);
  TextOut(surface, 5, 5, s.c_str(), s.size()); 

  s = "R - Reset";
  TextOut(surface, 5, m_cyClient-17, s.c_str(), s.size());

  s = "Enter - Start/Stop ";
  TextOut(surface, 200, m_cyClient-17, s.c_str(), s.size());
  
}

//--------------------------------- Epoch ----------------------------------
//
//  This method runs the app through one epoch of the GA. First it decodes
//  each member of the population. Then it checks to see if it is valid and
//  assigns a fitness score based on the size of its radius. If the 
//  tiddlywink overlaps or goes out of bounds it gets a zero score.
//
//  Once we've tested all the genomes they are evolved by the GA to produce
//  a new generation. 
//------------------------------------------------------------------------
void CController::Epoch()
{
  double BestFitnessSoFar = 0;

  for (int p=0; p<m_vecPop.size(); ++p)
  {
    //decode this genome
    double x,y,r;
  
    Decode(m_vecPop[p], x, y, r);
  
    double radius = r;
    
    //test the fitness of each tiddlywink in the population. the fitness
    //is proportional to its radius
    for (int i=0; i<m_vecTW.size(); ++i)
    {
      //first check to make sure this isn't enclosed in a circle or
      //enclosing a circle
      if (TwoCirclesOverlapped(m_vecTW[i].x,
                               m_vecTW[i].y,
                               m_vecTW[i].r,
                               x, y, r))
      {
        radius = 0; break;        
      }

      //check that tiddlywink is within window bounderies
      if ( (x+r > m_cxClient) || (y+r > m_cyClient) )
      {
        radius = 0; break;       
      }
      
    }//check next tw

    //assign radius to fitness
    m_vecPop[p].dFitness = radius;

    //keep a record of the best
    if (radius > BestFitnessSoFar)
    {
      BestFitnessSoFar = radius;

      m_iBest = p;
    } 

  }//next genome


  //now perform an epoch of the GA. First replace the genomes
  m_pGA->PutGenomes(m_vecPop);

  //let the GA do its stuff
  m_pGA->Epoch();

  //grab the new genome
  m_vecPop = m_pGA->GrabGenomes();

  ++m_iGeneration;
}

//--------------------------- RenderBestGenome ---------------------------
//
//  renders the best genome found so far in red
//------------------------------------------------------------------------
void CController::RenderBestGenome(HDC &surface)
{
  HBRUSH redBrush = CreateSolidBrush(RGB(255,0,0));

  HBRUSH oldBrush = (HBRUSH)SelectObject(surface, redBrush);
  
  //decode this genome
  double x,y,r;
  
  Decode(m_vecPop[m_iBest], x, y, r);
  
  //draw it
  Ellipse(surface, x-r, y-r, x+r, y+r);
 
  //tidy up
  SelectObject(surface, oldBrush);

  DeleteObject(redBrush);
  DeleteObject(oldBrush);
}

//----------------------------- Decode -----------------------------------
//
//  decodes the a genome and calculates the x,y and radius for the 
//  tiddlywink it represents
//------------------------------------------------------------------------
void CController::Decode(SGenome &gen, double &x, double &y, double &r)
{
  vector<int> DecGen = gen.Decode();

  //calculate the x,y, and radius of the circle
  double ConversionMultiplier = (double)m_cxClient/BIT_MULTIPLIER;
    
  r = DecGen[2] * ConversionMultiplier;

  ConversionMultiplier = ((double)m_cxClient - (2*r))/BIT_MULTIPLIER;

  x = DecGen[0] * ConversionMultiplier + r;
  y = DecGen[1] * ConversionMultiplier + r;
}