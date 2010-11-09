#include "Cga.h"

//--------------------------- ctor ---------------------------------------
//
//------------------------------------------------------------------------
SGenome::SGenome(const int num_bits,
                 const int gene_size):dFitness(0),
                                      iGeneLength(gene_size)
{

  //create a random bit string
  for (int i=0; i<num_bits; ++i)
  {
    vecBits.push_back(RandInt(0, 1));
  }
}

//----------------------CreateStartPopulation---------------------------
//
//-----------------------------------------------------------------------
void Cga::CreateStartPopulation()
{
	//clear existing population
	m_vecGenomes.clear();
	
	for (int i=0; i<m_iPopSize; i++)
	{
		m_vecGenomes.push_back(SGenome(m_iChromoLength, m_iGeneLength));
	}

	//reset all variables
	m_iGeneration		     = 0;
	m_dTotalFitnessScore = 0;
}


//-----------------------CalculateTotalFitness------------------------	
//

//---------------------------------------------------------------------
void Cga::CalculateTotalFitness()
{
	m_dTotalFitnessScore = 0;
	
	for (int i=0; i<m_iPopSize; ++i)
	{				
		m_dTotalFitnessScore	+= m_vecGenomes[i].dFitness;				
	}
}

//---------------------------Decode-------------------------------------
//
//	decodes a vector of bits into a vector of ints
//
//-----------------------------------------------------------------------
vector<int> SGenome::Decode()
{
	vector<int>	decoded;

	//step through the chromosome a gene at a time
	for (int gene=0; gene < vecBits.size(); gene += iGeneLength)
	{
		//get the gene at this position
		vector<int> ThisGene;
		
		for (int bit = 0; bit < iGeneLength; ++bit)
		{
			ThisGene.push_back(vecBits[gene+bit]);
		}

		//convert to decimal and add to list of decoded
		decoded.push_back(BinToInt(ThisGene));
	}

	return decoded;
}

//-------------------------------BinToInt-------------------------------
//
//	converts a vector of bits into an integer
//----------------------------------------------------------------------
int	SGenome::BinToInt(const vector<int> &vec)
{
	int val = 0;
	int multiplier = 1;
	
	for (int cBit=vec.size(); cBit>0; cBit--)
	{
		val += vec[cBit-1] * multiplier;
		
		multiplier *= 2;
	}

	return val;
}

//--------------------------RouletteWheelSelection-----------------
//
//	selects a member of the population by using roulette wheel 
//	selection as described in the text.
//------------------------------------------------------------------
SGenome& Cga::RouletteWheelSelection()
{
	double fSlice	= RandFloat() * m_dTotalFitnessScore;
	
	double cfTotal	= 0.0;
	
	int	SelectedGenome = 0;
	
	for (int i=0; i<m_iPopSize; ++i)
	{
		
		cfTotal += m_vecGenomes[i].dFitness;
		
		if (cfTotal > fSlice) 
		{
			SelectedGenome = i;
			break;
		}
	}
	
	return m_vecGenomes[SelectedGenome];
}

//----------------------------Mutate---------------------------------
//	iterates through each genome flipping the bits acording to the
//	mutation rate
//--------------------------------------------------------------------
void Cga::Mutate(vector<int> &vecBits)
{
	for (int curBit=0; curBit<vecBits.size(); curBit++)
	{
		//do we flip this bit?
		if (RandFloat() < m_dMutationRate)
		{
			//flip the bit
			vecBits[curBit] = !vecBits[curBit];
		}
	}//next bit
}

//----------------------------Crossover--------------------------------
//	Takes 2 parent vectors, selects a midpoint and then swaps the ends
//	of each genome creating 2 new genomes which are stored in baby1 and
//	baby2.
//---------------------------------------------------------------------
void Cga::Crossover( const vector<int> &mum,
						const vector<int> &dad,
						vector<int>		  &baby1,
						vector<int>		  &baby2)
{
	//just return parents as offspring dependent on the rate
	//or if parents are the same
	if ( (RandFloat() > m_dCrossoverRate) || (mum == dad)) 
	{
		baby1 = mum;
		baby2 = dad;

		return;
	}
	
	//determine a crossover point
	int cp = RandInt(0, m_iChromoLength - 1);

	//swap the bits
	for (int i=0; i<cp; ++i)
	{
		baby1.push_back(mum[i]);
		baby2.push_back(dad[i]);
	}

	for (i=cp; i<mum.size(); ++i)
	{
		baby1.push_back(dad[i]);
		baby2.push_back(mum[i]);
	}
}

//-------------------------GrabNBest----------------------------------
//
//	This works like an advanced form of elitism by inserting NumCopies
//  copies of the NBest most fittest genomes into a population vector
//--------------------------------------------------------------------
void Cga::GrabNBest(int				      NBest,
					          const int       NumCopies,
					          vector<SGenome>	&vecNewPop)
{

	sort(m_vecGenomes.begin(), m_vecGenomes.end());

	//now add the required amount of copies of the n most fittest 
	//to the supplied vector
	while(NBest--)
	{
		for (int i=0; i<NumCopies; ++i)
		{
			vecNewPop.push_back(m_vecGenomes[NBest]);
		}
	}
}


//--------------------------------Epoch---------------------------------
//
//	This is the workhorse of the GA. It first updates the fitness
//	scores of the population then creates a new population of
//	genomes using the Selection, Croosover and Mutation operators
//	we have discussed
//----------------------------------------------------------------------
void Cga::Epoch()
{
	//Now to create a new population
	int NewBabies = 0;

  CalculateTotalFitness();

	//create some storage for the baby genomes 
	vector<SGenome> vecBabyGenomes;

  //Now to add a little elitism we shall add in some copies of the
	//fittest genomes
	  
	//make sure we add an EVEN number or the roulette wheel
	//sampling will crash
	if (!(NUM_COPIES_ELITE  * NUM_ELITE % 2))
	{
		GrabNBest(NUM_ELITE, NUM_COPIES_ELITE, vecBabyGenomes);
	}

	while (vecBabyGenomes.size() < m_iPopSize)
	{
		//select 2 parents
		SGenome mum = RouletteWheelSelection();
		SGenome dad = RouletteWheelSelection();

		//operator - crossover
		SGenome baby1, baby2;
		Crossover(mum.vecBits, dad.vecBits, baby1.vecBits, baby2.vecBits);

		//operator - mutate
		Mutate(baby1.vecBits);
		Mutate(baby2.vecBits);

		//add to new population
		vecBabyGenomes.push_back(baby1);
		vecBabyGenomes.push_back(baby2);

		NewBabies += 2;
	}

	//copy babies back into starter population
	m_vecGenomes = vecBabyGenomes;

	//increment the generation counter
	++m_iGeneration;
}







