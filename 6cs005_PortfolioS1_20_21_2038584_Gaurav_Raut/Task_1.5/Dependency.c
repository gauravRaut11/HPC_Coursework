#include <stdio.h>
//compile with "gcc Dependency.c -o dependency"
int main() {  
//Assigning values to variables
   int A=10;
   int B=20;
   int C=30;
   int D=40;
   
//assigning temporary variable to B and C 
   int cTemp=C;
   int bTemp=B;
   
//Executing function  
    bTemp=A+C;
    B=cTemp+D;
    C=B+D;
 
//Printing output
    printf("Result after removing dependencies:\n");
    printf("A=%d\n",A); 
    printf("B=%d\n",B);  
    printf("C= %d\n", C);  
    printf("D= %d\n", D);
    
    return 0;
}
