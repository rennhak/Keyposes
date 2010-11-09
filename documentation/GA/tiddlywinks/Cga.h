#ifndef Cga_H
#define Cga_H

/////////////////////////////////////////////////////////////////////////
//
//		File: Cga.h
//
//		Author: Mat Buckland
//
//		Desc: definition of the SGenome class and the genetic algorithm
//			  class 
//
/////////////////////////////////////////////////////////////////////////

#include <vector>
#include <algorithm>

#include "defines.h"
#include "utils.h"


using namespace std;



//--------------------------------------------------------------
//	define our genome structure
//--------------------------------------------------------------
struct SGenome
{
  vector<int> vecBits;
	
  double      dFitness;

  //how many bits per gene
  int	        iGeneLength;
	

  SGenome():dFitness(0), iGeneLength(GENE_LENGTH){}
	
  SGenome(const int num_bits, const int gene_size);

  //decodes each gene into decimal
  vector<int> Decode();
	
  int         BinToInt(const vector<int> &v);

  //overload '<' used for sorting
	friend bool operator<(const SGenome& lhs, const SGenome& rhs)
	{
		return (lhs.dFitness > rhs.dFitness);
	}
};


//--------------------------------------------------------------
//	define our genetic algorithm class
//---------------------------------------------------------------
class Cga
{
private:

  //our population of genomes
  vector<SGenome>	m_vecGenomes;
	
  int             m_iPopSize;

  double          m_dCrossoverRate;
	
  double          m_dMutationRate;
	
  //how many bits per chromosome
  int             m_iChromoLength;

  //how many bits per gene
  int	            m_iGeneLength;
	
  double          m_dTotalFitnessScore;
	
  int             m_iGeneration;



  void        Mutate(vector<int> &vecBits);
	
  void        Crossover(const vector<int> &mum,
                        const vector<int> &dad,
                        vector<int>       &baby1,
                        vector<int>       &baby2);
	
  SGenome&    RouletteWheelSelection();

  void        GrabNBest(int				      NBest,
					              const int       NumCopies,
					              vector<SGenome>	&vecNewPop);

  

  void        CreateStartPopulation();

  void        CalculateTotalFitness();



public:
	
  Cga(double  cross_rat,
      double  mut_rat,
      int     pop_size,
      int     num_bits,
      int     gene_len):m_dCrossoverRate(cross_rat),
                        m_dMutationRate(mut_rat),
                        m_iPopSize(pop_size),
                        m_iChromoLength(num_bits),
							          m_dTotalFitnessScore(0.0),
							          m_iGeneration(0),
							          m_iGeneLength(gene_len)
				
		
	{
		CreateStartPopulation();
	}
	
	//This is the workhorse of the GA. It first updates the fitness
  //scores of the population then creates a new population of
  //genomes using the Selection, Croosover and Mutation operators
  //we have discussed
  void        Epoch();
  	
	//accessor methods
  vector<SGenome> GrabGenomes(){return m_vecGenomes;}
  void            PutGenomes(vector<SGenome> gen){m_vecGenomes = gen;}

};


#endif