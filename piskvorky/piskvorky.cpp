#include <iostream>
#include <stdio.h>
#include <string>
//#include <SDL.h>
#include <string.h>
#include <typeinfo>
#include "vykreslitabulku.h"
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
	string uvod = "Vitejte ve hre PISKVORKY [version 1.6]";

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

			if (pole[i][j] == NONE) symbol = ('1' + (i * 3) + j);
												
			else symbol = reprezentace(pole[i][j]);
			
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

       if(!cin.fail()) break;	  
   }

   return volbahrace;
}

void zmenapole(int delka, int sirka, int *radek, int *sloupec)
{
    int volbahrace = 0;		
	volbahrace = spravny_typ();
								
	while ((volbahrace > (delka*sirka)) || (volbahrace < 1))
	{
		std::cout << "Spatne - znova: " << endl;
		volbahrace = spravny_typ();
	}

	*radek = ((volbahrace - 1) / delka);
	*sloupec = ((volbahrace - 1) % delka);

	while(pole[*radek][*sloupec] != NONE)
	{
		std::cout << "Pole je jiz OBSAZENE, vyber si jine:" << endl;
		std::cout << "--> ";
		std::cin >> volbahrace;
		
		*radek = ((volbahrace - 1) / delka);
		*sloupec = ((volbahrace - 1) % delka);
	}

	pole[*radek][*sloupec] = aktivni_hrac;
}

void zmenahrace()
{
	aktivni_hrac = (aktivni_hrac == O) ? X : O;
}

char Vitez_diagonala(int pocet_viteznych, int radek, int sloupec)
{
	int pocet_X = 0;
	int pocet_O = 0;
	int pocet_X_diagonala = 0;
	int pocet_O_diagonala = 0;
	int hodnota1 = radek;
	int hodnota2 = sloupec;
	int hodnota3 = radek;
	int hodnota4 = sloupec;
	int p = 0; 
	char vysledny_znak = '0';
	
	while(p < pocet_viteznych)
	{
		if(pole[hodnota1][hodnota2] == 1) pocet_O++;
		
		if(pole[hodnota1][hodnota2] == 2) pocet_X++;

		if(pole[hodnota3][hodnota4] == 1) pocet_O_diagonala++;
		
		if(pole[hodnota3][hodnota4] == 2) pocet_X_diagonala++;		
		
		hodnota1++;
		hodnota2++;
		hodnota3++;
		hodnota4--;
		p++;
	}

	vysledny_znak = ((pocet_X == pocet_viteznych) ? 'X' : (pocet_O == pocet_viteznych) ? 'O' : (pocet_X_diagonala == pocet_viteznych) ? 'X' : (pocet_O_diagonala == pocet_viteznych) ? 'O' : '/');

	if(vysledny_znak != '/') return vysledny_znak;

	else
	{
		p = 0;
		pocet_X = 0;
		pocet_O = 0;
		pocet_X_diagonala = 0;
		pocet_O_diagonala = 0;
		hodnota1 = radek;
		hodnota2 = sloupec;
		hodnota3 = radek;
		hodnota4 = sloupec;

		while(p < pocet_viteznych)
		{
			if(pole[hodnota1][hodnota2] == 1) pocet_O++;
		
			if(pole[hodnota1][hodnota2] == 2) pocet_X++;

			if(pole[hodnota3][hodnota4] == 1) pocet_O_diagonala++;
		
			if(pole[hodnota3][hodnota4] == 2) pocet_X_diagonala++;

			hodnota1--;
			hodnota2--;
			hodnota3--;
			hodnota4++;
			p++;
		}

		vysledny_znak = ((pocet_X == pocet_viteznych) ? 'X' : (pocet_O == pocet_viteznych) ? 'O' : (pocet_X_diagonala == pocet_viteznych) ? 'X' : (pocet_O_diagonala == pocet_viteznych) ? 'O' : '/');
		return vysledny_znak;
	}
}

char Vitez_vertikal_horizontal(int pocet_viteznych, int radek, int sloupec)
{
	int pocet_X = 0;
	int pocet_O = 0;
	int pocet_X_sloupec = 0;
	int pocet_O_sloupec = 0;
	int hodnota1 = radek;
	int hodnota2 = sloupec;
	int hodnota3 = radek;
	int hodnota4 = sloupec;
	char vysledny_znak = '0';

	int p = 0; 
	
	while(p < pocet_viteznych)
	{
		if(pole[hodnota1][hodnota2] == 1) pocet_O++;
		
		if(pole[hodnota1][hodnota2] == 2) pocet_X++;

		if(pole[hodnota3][hodnota4] == 1) pocet_O_sloupec++;
		
		if(pole[hodnota3][hodnota4] == 2) pocet_X_sloupec++;
		
		p++;
		hodnota2--;
		hodnota3--;
	}

	vysledny_znak = ((pocet_X == pocet_viteznych) ? 'X' : (pocet_O == pocet_viteznych) ? 'O' : (pocet_X_sloupec == pocet_viteznych) ? 'X' : (pocet_O_sloupec == pocet_viteznych) ? 'O' : '/');

	if(vysledny_znak != '/') return vysledny_znak;

    else
	{
		p = 0;
		pocet_X = 0;
		pocet_O = 0;
		pocet_X_sloupec = 0;
		pocet_O_sloupec = 0;
		hodnota1 = radek;
		hodnota2 = sloupec;
		hodnota3 = radek;
		hodnota4 = sloupec;

		while(p < pocet_viteznych)
		{
			if(pole[hodnota1][hodnota2] == 1) pocet_O++;
		
			if(pole[hodnota1][hodnota2] == 2) pocet_X++;

			if(pole[hodnota3][hodnota4] == 1) pocet_O_sloupec++;
		
			if(pole[hodnota3][hodnota4] == 2) pocet_X_sloupec++;
		
			p++;
			hodnota2++;
			hodnota3++;
		}

		vysledny_znak = ((pocet_X == pocet_viteznych) ? 'X' : (pocet_O == pocet_viteznych) ? 'O' : (pocet_X_sloupec == pocet_viteznych) ? 'X' : (pocet_O_sloupec == pocet_viteznych) ? 'O' : '/');
		return vysledny_znak;	
	}
}

char Vitez(int pocet_viteznych, int radek, int sloupec)
{
	if(Vitez_vertikal_horizontal(pocet_viteznych, radek, sloupec) == 'X' || Vitez_diagonala(pocet_viteznych, radek, sloupec) == 'X') return 'X';
	
	if(Vitez_vertikal_horizontal(pocet_viteznych, radek, sloupec) == 'O' || Vitez_diagonala(pocet_viteznych, radek, sloupec) == 'O') return 'O';
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

	if (moznost == 1) return 1;
	
	else if (moznost == 2) return 2;
	
	return 0;
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
	int radek = 0;
	int sloupec = 0;

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

		if ((volba != 'x') && (volba != 'o')) std::cout << "Nauc se cist matlo!... :(" << endl;
		
		for (p = 0; p < (delka * sirka); p++)
		{
			cout << " Tah hrace: " << reprezentace(aktivni_hrac) << endl;
			cout << "Ktery si rika: " << prezdivka[aktivni_hrac] << endl;
			std::cout << endl;

			vypsanipole(delka, sirka);

			zmenapole(delka, sirka, &radek, &sloupec);
			
			//vykresli();
									
			std::cout << endl;
			system("cls");
			
			vitezny_symbol = Vitez(pocet_viteznych,radek, sloupec);

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

	else std::cout << "KONEC!" << endl;
	
	return 0;
}
