#ifndef CCONTROLLER_H
#define CCONTROLLER_H

/////////////////////////////////////////////////////////////////////////
//
//		File: CController.h
//
//		Author: Mat Buckland
//
//		Desc: Controller class for the tiddlywink GA example program 
//
/////////////////////////////////////////////////////////////////////////

#include <windows.h>
#include <vector>
#include <math.h>

#include "utils.h"
#include "Cga.h"
#include "geometry.h"

using namespace std;

//------------------------------------------------------------------------
//
//  define a tiddlywink structure
//------------------------------------------------------------------------
struct  STiddlywink
{
  //position
  int     x,y;

  //radius
  double  r;

  STiddlywink(int _x, int _y, int _r):x(_x),
                                      y(_y),
                                      r(_r)
  {}

  void Render(HDC &surface);
};

//------------------------------------------------------------------------
//
//  define the controller class. This class acts as an interface between
//  the GA, the tiddlywinks and the user.
//------------------------------------------------------------------------
class CController
{
private:

  //instance of the GA class
  Cga*                m_pGA;

  //local copy of the population of genomes
  vector<SGenome>     m_vecPop;

  //local copy of client window size
  int                 m_cxClient,
                      m_cyClient;

  //the static tiddlywinks the GA must fit between
  vector<STiddlywink> m_vecTW;

  int                 m_iNumTWinks,  //num tiddlywinks
                      m_iMinRad,     //min radius 
                      m_iMaxRad;     //max radius

  //index into the fittest genome in the population
  int m_iBest;

  //lets us know if the current run is in progress
	//used in our rendering function
	bool				  m_bStarted;

  int           m_iGeneration;



  bool  Overlapped(const STiddlywink &tw);
  
  void  RenderBestGenome(HDC &surface);

  void  Decode(SGenome &gen, double &x, double &y, double &r);


public:

  CController():m_cxClient(0), m_cyClient(0), m_pGA(NULL){}

  ~CController()
  {
    delete m_pGA;
  }

  void Render(HDC &surface);

  void Reset();

  void Init(int cyClient, int cxClient, int NumTWinks, int minRad, int maxRad);

  void Epoch();

 
  void ToggleStarted()  {m_bStarted = !m_bStarted;}
  bool Started(){return m_bStarted;}

};


#endif
  
