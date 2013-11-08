/*************************************
* Program: DP.cpp
* Description: Computes pairwise sequence alignment and prints DP matrix
* Author: Steven Ahrendt
* email: sahrendt0@gmail.com
* Date: 4.22.11
*         v 0.5:  All values hard-coded
*                 no BLOSUM lookup
*         v 1.0:  BLOSUM50 lookup
*                 table stored as file
*                 sequences hard-coded
**************************************
* Usage: DP < BLOSUM50
**************************************/

#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <cstdlib>
#include <string>
#include <vector>

using namespace std;

static int GAP_OPEN = 8;
//static int GAP_EXTEND = 8;
static int BLOSUM_SIZE = 25;
static string SEQ1 = "FIPFSAGPQQPPPDAEKDIGCIADIGKEDIAKSD";
static string SEQ2 = "GAGSDHFDADKIKISSMMWISKAIDKGIHIDLP";

static int** BLOSUM50;

int numWidth(int n)
{
  int result = 0;
  if(n < 0)
  {
    result++;
  }
  double t = (double)abs(n);
  while(t >= 1)
  {
    result++;
    t /=10;
  }
  return result;
} //numWidth(int)

int** matrixInit(int rows, int cols)
{
  int** result = new int*[rows];
  for(int i=0;i<rows;i++)
  {
    result[i] = new int[cols];
    for(int j=0;j<cols;j++)
    {
      result[i][j] = 0;
    }
  }
  return result;
} //matrixInit(int,int)

void printMatrix(int** m, int r, int c)
{

  int wformat = 1;

  //Scan matrix for widest value
  for(int i=1;i<r;i++)
  {
    for(int j=1;j<c;j++)
    {
      int nw = numWidth(m[i][j]);
      //cout << nd << endl;
      if(nw > wformat)
      {
        wformat = nw;
      }
    }
  }

  for(int i=0;i<r;i++)
  {
    for(int j=0; j<c;j++)
    {
      if((i==0) || (j==0))
      {
        printf("%*c ",wformat,m[i][j]);
      }
      else
      {
        printf("%*d ",wformat,m[i][j]);
      }
    }
    cout << endl;
  }
} //printMatrix(int**,int,int)

void printSolMatrix(int** m, string seq1, string seq2)
{

  int c = seq2.size()+1;
  int r = seq1.size()+1;

  int wformat = 1;

  //Scan matrix for widest value
  for(int i=0;i<r;i++)
  {
    for(int j=0;j<c;j++)
    {
      int nw = numWidth(m[i][j]);
      //cout << nd << endl;
      if(nw > wformat)
      {
        wformat = nw;
      }
    }
  }

  cout << "  ";
  for(int w=0;w<wformat;w++)
  {
    cout << " ";
  }
  cout << " ";
  for(unsigned int s=0;s<seq2.size();s++)
  {
    printf("%*c ",wformat,seq2.at(s));
  }
  cout << endl;  

  for(int i=0;i<r;i++)
  {
    if(i>0)
    {
      cout << seq1.at(i-1);
    }
    else
    {
      cout << " ";
    }
    cout << " ";
    for(int j=0; j<c;j++)
    {
       printf("%*d ",wformat,m[i][j]);
    }
    cout << endl;
  }
} //printSolMatrix(int**,int,int)


void printTbMatrix(char** tb, string seq1, string seq2)
{
  int c = seq2.size()+1;
  int r = seq1.size()+1;

  cout << "    ";
  for(unsigned int s=0;s<seq2.size();s++)
  {
    cout << seq2.at(s) << " ";
  } 
  cout << endl;
  for(int i=0;i<r;i++)
  {
    for(int j=0;j<c;j++)
    {
      if((i==0) && (j==0))
      { 
        cout << "  -";
      }
      if((i>0) && (j==0))
      {
        cout << seq1.at(i-1) << " ";
      }
      cout << tb[i][j] << " ";
    }
    cout << endl;
  }
} //printTbMatrix(char**,string,string)

int score(char a, char b)
{
  char tmp;  
  
  int a_index = 0;
  int b_index = 0;

  //cout << "a: " << a << endl;
  //cout << "b: " << b << endl;

  for(int i=0;i<BLOSUM_SIZE;i++)
  {
    tmp = BLOSUM50[i][0];
    if(tmp == a)
    {
      a_index = i;
    }
    //cout << tmp << endl;
  }
  for(int j=0;j<BLOSUM_SIZE;j++)
  {
    tmp = BLOSUM50[0][j];
    if(tmp == b)
    {
      b_index = j;
    }
  }

  return BLOSUM50[a_index][b_index];
} //score(char,char)

int** blosum(int type)
{
  int** b = new int*[BLOSUM_SIZE];
  char c;
  int x;
  for(int i=0; i<BLOSUM_SIZE;i++)
  {
    b[i] = new int[BLOSUM_SIZE];
    for(int j=0;j<BLOSUM_SIZE;j++)
    {
      if((i==0) || (j==0))
      {
        cin >> c;
        //cout << c << " ";
        b[i][j] = (int)c;
      }
      else
      {
        cin >> x;
        //cout << x << " ";
        b[i][j] = x;
      }
    }
    //cout << endl;
  }
  return b;
} //blosum(type)

void printAlign(char** tb, string seq1, string seq2)
{
  int r = seq1.size();
  int c = seq2.size();

  vector<char> align1;
  vector<char> align2;  

  //cout << tb[r][c] << endl;
  
  while((c>0) || (r>0))
  {
    switch(tb[r][c])
    {
      case 'U': align1.insert(align1.begin(),seq1.at(r-1)); align2.insert(align2.begin(),'-'); r--;
        break;
      case 'L': align1.insert(align1.begin(),'-'); align2.insert(align2.begin(),seq2.at(c-1)); c--;
        break;
      case 'D': align1.insert(align1.begin(),seq1.at(r-1)); align2.insert(align2.begin(),seq2.at(c-1)); r--; c--;
        break;
    }
  }
  
  cout << "Alignment: " << endl;
  cout << "Seq1: ";  
  for(unsigned int i=0;i<align1.size(); i++)
  {
    cout << align1.at(i);
  }
  cout << endl;
  cout << "Seq2: ";
  for(unsigned int j=0;j<align2.size();j++)
  {
    cout << align2.at(j);
  }
  cout << endl;
} //printAlign(char**,string,string)

void DP(int** m, int r, int c, string seq1, string seq2)
{
  int gp = GAP_OPEN;  

  // Set up traceback matrix
  char** tb = new char*[r];
  for(int x=0;x<r;x++)
  {
    tb[x] = new char[c];
  }

  // Compute Dynamic programming matrix
  for(int i=0;i<r;i++)
  {
    for(int j=0;j<c;j++)
    { 
      if((i==0) && (j>0))
      {
        m[i][j] = m[i][(j-1)] - gp;
        tb[i][j] = 'L';
      }
      if((j==0) && (i>0))
      {
        m[i][j] = m[(i-1)][j] - gp;
        tb[i][j] = 'U';
      }
      if((i>0) && (j>0))
      {
        m[i][j] = max( max( m[(i-1)][j]-gp,m[i][(j-1)]-gp ), m[(i-1)][(j-1)] + score(seq1.at((i-1)),seq2.at((j-1))) );
        if(m[i][j] == m[(i-1)][j]-gp)
        {
          tb[i][j] = 'U';
        }
        else if(m[i][j] == m[i][(j-1)]-gp)
        {
          tb[i][j] = 'L';
        }
        else
        {
          tb[i][j] = 'D';
        }
      }
    }
  }

  // Print Matrix
  printSolMatrix(m,seq1,seq2);
  cout << endl;
  // Show Score
  cout << "Final Score: " << m[r-1][c-1] << endl;
  cout << endl;
  // Print alignment
  printAlign(tb,seq1,seq2);
} //DP(int**,int,int,string,string)


int main()
{
  int rows = SEQ1.size()+1;
  int cols = SEQ2.size()+1;
  int** m = matrixInit(rows,cols);
  BLOSUM50 = blosum(50);
  
  DP(m,rows,cols,SEQ1,SEQ2);

  return 0;
} // main()

