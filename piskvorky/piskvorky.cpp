#include <iostream>
#include <stdio.h>
#include <string>
#include <SDL.h>
#include <string.h>
#include <typeinfo>
#include "Vykreslitabulku.h"
#include <limits>

using namespace std;

int delka_tabulky = 0;
int sirka_tabulky = 0;

char hrac = 'X';
char prezdivka1[100];
char prezdivka2[100];

enum strany { NONE, O, X };
strany aktivni_hrac = X;
string prezdivka[X + 1];
strany pole[1000][1000];

char reprezentace(strany a)
{
	return a == X ? 'X' : a == O ? 'O' : ' ';
}

void zarovnani()
{
	int sirka = 200;
	int i = 0;
	string uvod = "Vitejte ve hre PISKVORKY [version 1.5]"; //vzor pro zarovnani ostatnich

	while (uvod[i] != '\0')
	{
		i++;
	}
	for (int j = 0; j < ((sirka - i) / 2); i++)
	{
		std::cout << " ";
	}
}

void nastaveni(int *sirka, int *delka, int *pocet_viteznych)
{
	zarovnani();
	std::cout << "Delka pole: " << endl;
	std::cout << "--> ";
	std::cin >> (*delka);

	zarovnani();
	std::cout << "Sirka pole: " << endl;
	std::cout << "--> ";
	std::cin >> (*sirka);

	zarovnani();
	std::cout << "Vyber pocet viteznych znaku (stejneho hrace) za sebou: " << endl;
	std::cout << "--> ";
	std::cin >> (*pocet_viteznych);

	system("cls");
}

void vypsanipole(int delka, int sirka)
{
	for (int i = 0; i < delka; i++)
	{
		for (int j = 0; j < sirka; j++)
		{
			char symbol;

			if (pole[i][j] == NONE)
			{
				symbol = ('1' + (i * 3) + j);
			}
			
									
			else
			{
				symbol = reprezentace(pole[i][j]);
			}
				
			std::cout << symbol << " | ";
		}
		std::cout << endl;
	}
}

int spravny_typ()
{
    int volbahrace;

    std::cout << "Kam chces hrat ted?: " << endl;
	std::cout << "--> ";
	std::cin >> volbahrace;

    while(1)
   {
       if(cin.fail())
       {
           cin.clear();
           cin.ignore(numeric_limits<streamsize>::max(), '\n');
           std::cout << "Spatna volba - znova: " << endl;
           std::cin >> volbahrace;
       }

       if(!cin.fail())
	   {
		   break;
	   }
   }

   return volbahrace;
}

void zmenapole(int delka, int sirka)
{
    int volbahrace = 0;
	int radek, sloupec = 0;	
	
	volbahrace = spravny_typ();
								
	while ((volbahrace > (delka*sirka)) || (volbahrace < 1))
	{
		std::cout << "Spatne - znova: " << endl;
		volbahrace = spravny_typ();
	}

	radek = ((volbahrace - 1) / delka);
	sloupec = ((volbahrace - 1) % delka);

	while(pole[radek][sloupec] != NONE)
	{
		std::cout << "Pole je jiz OBSAZENE, vyber si jine:" << endl;
		std::cout << "--> ";
		std::cin >> volbahrace;
		
		radek = ((volbahrace - 1) / delka);
		sloupec = ((volbahrace - 1) % delka);
	}

	pole[radek][sloupec] = aktivni_hrac;
}

void zmenahrace()
{
	aktivni_hrac = (aktivni_hrac == O) ? X : O;
}

char Vitez(int pocet_viteznych, int delka, int sirka)
{
	int ukazatelX = 0;
	int ukazatelO = 0;
	//musím si vytvořit samostatnou proměnou na sloupce, protože jinak kdyby byly pod sebou např. xxx tak by ten ukazatelX nabil hodnoty 4...
	int ukazatelXsloupce = 0;
	int ukazatelOsloupce = 0;

	for (int i = 0; i < delka; i++)
	{
		for (int j = 0; j < sirka; j++)
		{
			if (pole[i][j] == 'X')
			{
				ukazatelX++;
			}

			if (pole[i][j] == 'O')
			{
				ukazatelO++;
			}

			if (pole[j][i] == 'X')
			{
				ukazatelXsloupce++;
			}

			if (pole[j][i] == 'O')
			{
				ukazatelOsloupce++;
			}			
		}

		if ((ukazatelX == pocet_viteznych) || (ukazatelXsloupce == pocet_viteznych))
		{
		    return 'X';
			break;
		}

		if ((ukazatelO == pocet_viteznych) || (ukazatelOsloupce == pocet_viteznych))
		{
		    return 'O';
			break;
		}	

		ukazatelX = 0;
		ukazatelO = 0;
		ukazatelXsloupce = 0;
		ukazatelOsloupce = 0;
	}

	/*if ((pole[0][0] == 'X' && pole[1][1] == 'X' && pole[2][2] == 'X') || (pole[0][2] == 'X' && pole[1][1] == 'X' && pole[2][0] == 'X'))
	{
		return 'X';
	}

	else if ((pole[0][0] == 'O' && pole[1][1] == 'O' && pole[2][2] == 'O') || (pole[0][2] == 'O' && pole[1][1] == 'O' && pole[2][0] == 'O'))
	{
		return 'O';
	}*/

	return '/';
}

int uvitaciobrazovka()
{
	int moznost = 0;
	
	zarovnani();
	std::cout << "Vitejte ve hre PISKVORKY [version 1.4]" << endl;
		
	zarovnani();
	std::cout << "Zacit hrat...1" << endl;	

	zarovnani();
	std::cout << "Ukoncit program...2" << endl;

	zarovnani();
	std::cout << "--> ";
	std::cin >> moznost;

	while((moznost > 2) || (moznost < 1))
	{
		zarovnani();
		std::cout << "Zkus to znovu: " << endl;
		zarovnani();
		std::cout << "--> ";
		std::cin >> moznost;
	}	

	system("cls");

	if (moznost == 1)
	{
		return 1;
	}

	else if (moznost == 2)
	{
		return 2;
	}	
}

int main(int argc, char *argv[])
{
	FILE* f;
	f = fopen("Historie vitezu.txt", "w+");
	int p = 0;
	char volba1[2];
	char vitezny_symbol = '0';
	int pocet_viteznych = 0;
	int delka = 0;
	int sirka = 0;

	if (uvitaciobrazovka() == 1)
	{
		char volba = '0';
		nastaveni(&delka, &sirka, &pocet_viteznych);

		std::cout << " Zacina hrac X [stiskni x]" << endl;
		std::cout << " Zacina hrac O [stikni o]" << endl;
		std::cout << endl;

		std::cout << "Kdo zacne?: " << endl;
		std::cout << "--> ";
		std::cin >> volba;

		system("cls");

		aktivni_hrac = (volba == 'x') ? X : O;

		for (int i = 0; i < 2; i++)
		{
			std::cout << "Hrac " << reprezentace(aktivni_hrac) << " si vybere prezdivku: " << endl;
			std::cout << "--> ";
			std::cin >> prezdivka[aktivni_hrac];

			zmenahrace();
		}

		system("cls");

		if ((volba != 'x') && (volba != 'o'))
		{
			std::cout << "Nauc se cist matlo!... :(" << endl;
		}

		for (p = 0; p < (delka * sirka); p++)
		{
			cout << " Tah hrace: " << reprezentace(aktivni_hrac) << endl;
			cout << "Ktery si rika: " << prezdivka[aktivni_hrac] << endl;
			std::cout << endl;

			vypsanipole(delka, sirka);

			zmenapole(delka, sirka);
			
			//vykresli();
									
			std::cout << endl;
			system("cls");

			vitezny_symbol = Vitez(pocet_viteznych, delka, sirka);

			if (vitezny_symbol == 'X')
			{
				std::cout << "Vitezem je hrac: 'X' " << ", ktery si rika: " << prezdivka1 << endl;
				std::cout << "Chces se zapsat do historie?:[a/n]" << endl;
				std::cout << "--> ";
				std::cin >> volba1;

				if (volba1[0] == 'a')
				{
					fprintf(f, "Vitezem je:  %s", prezdivka1);

					fprintf(f, "\n");

					break;
				}

				break;
			}

			else if(vitezny_symbol == 'O')
			{
				std::cout << "Vitezem je hrac: 'O' " << ", ktery si rika: " << prezdivka2 << endl;
				std::cout << "Chces se zapsat do historie?:" << endl;
				std::cout << "--> ";
				std::cin >> volba1;

				if (volba1[0] == 'a')
				{
					fprintf(f, "Vitezem je:  %s", prezdivka2);

					fprintf(f, "\n");

					break;
				}

				break;
			}

			zmenahrace();	    	

			if (p == ((delka * sirka) - 1))
			{
				std::cout << "REMIZA" << endl;
				break;
			}
		}
	}   

	else
	{
		std::cout << "KONEC!" << endl;
	}

	return 0;
}
