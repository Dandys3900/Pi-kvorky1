#include <iostream>
#include <stdio.h>
#include "SDL.h"
#include <string> 
#include <typeinfo>

using namespace std;
int const sirka = 10;
int const delka = 10;

char hrac = 'X';
char prezdivka1[100];
char prezdivka2[100];

enum strany { NONE, O, X }; //no jo jsme narod zlodeju...
strany aktivni_hrac = X;
strany pole[delka][sirka];
string prezdivka[X + 1];

char reprezentace(strany a)
{
	return a == X ? 'X' : a == O ? 'O' : ' ';
}

void vypsanipole()
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
		cout << endl;
	}
}

void zmenapole()
{
	int volbahrace = 0;
	int radek, sloupec = 0;

	std::cout << "Kam chces hrat ted?: " << endl;
	std::cin >> volbahrace;
								
	while ((volbahrace > (delka*sirka)) || (volbahrace < 1))
	{
		std::cout << " Spatna volba - znova: " << endl;
		std::cin >> volbahrace;
	}
	
	radek = ((volbahrace - 1) / delka);
	sloupec = ((volbahrace - 1) % delka);

	if (pole[radek][sloupec] != NONE)
	{
		std::cout << "Pole je jiz OBSAZENE, vyber si jine:" << endl;
		std::cin >> volbahrace;

		radek = ((volbahrace - 1) / delka);
		sloupec = ((volbahrace - 1) % delka);

		if (pole[radek][sloupec] != NONE)
		{
			std::cout << "Zase spatne, inu komu neni radi..." << endl;
		}

		else
		{
			pole[radek][sloupec] = aktivni_hrac;
			vypsanipole();
		}
	}

	pole[radek][sloupec] = aktivni_hrac;
}

void zmenahrace()
{
	aktivni_hrac = (aktivni_hrac == O) ? X : O;
}

char Vitez()
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
				ukazatelX = ukazatelX + 1;
			}

			if (pole[i][j] == 'O')
			{
				ukazatelO = ukazatelO + 1;
			}

			if (pole[j][i] == 'X')
			{
				ukazatelXsloupce = ukazatelXsloupce + 1;
			}

			if (pole[j][i] == 'O')
			{
				ukazatelOsloupce = ukazatelOsloupce + 1;
			}
		}

		if ((ukazatelX == delka) || (ukazatelXsloupce == sirka))
		{
			return 'X';
		}

		else if ((ukazatelO == delka) || (ukazatelOsloupce == sirka))
		{
			return 'O';
		}

		ukazatelX = 0;
		ukazatelO = 0;
		ukazatelXsloupce = 0;
		ukazatelOsloupce = 0;
	}

	if ((pole[0][0] == 'X' && pole[1][1] == 'X' && pole[2][2] == 'X') || (pole[0][2] == 'X' && pole[1][1] == 'X' && pole[2][0] == 'X'))
	{
		return 'X';
	}

	else if ((pole[0][0] == 'O' && pole[1][1] == 'O' && pole[2][2] == 'O') || (pole[0][2] == 'O' && pole[1][1] == 'O' && pole[2][0] == 'O'))
	{
		return 'O';
	}

	return '/';
}

void zmenaprezdivky()
{
	if (hrac == 'X')
	{
		std::cout << "Ktery si rika: " << prezdivka1 << endl;
	}

	else if (hrac == 'O')
	{
		std::cout << "Ktery si rika: " << prezdivka2 << endl;
	}
}

int uvitaciobrazovka()
{
	int moznost = 0;

	std::cout << "VITEJTE VE HRE PISKVORKY" << endl;
	std::cout << "Co ted?: " << endl;

	std::cout << endl;

	std::cout << "Zacit hrat...1" << endl;
	std::cout << "Ukoncit program...2" << endl;
	std::cin >> moznost;

	if (moznost == 1)
	{
		return 1;
	}

	else
	{
		return 2;
	}
}

int main(int argc, char *argv[])
{
	FILE* f;
	int p = 0;
	char volba1[2];

	if (uvitaciobrazovka() == 1)
	{
		int volba = 0;

		std::cout << " Zacina hrac X ... 1" << endl;
		std::cout << " Zacina hrac O ... 2" << endl;
		std::cout << endl;

		std::cout << "Kdo zacne?: " << endl;
		std::cin >> volba;

		aktivni_hrac = (volba == 1) ? X : O;

		for (int i = 0; i < 2; i++)
		{
			std::cout << "Hrac " << reprezentace(aktivni_hrac) << " si vybere prezdivku: " << endl;
			std::cin >> prezdivka[aktivni_hrac];
			zmenahrace();
		}

		if (volba > 2)
		{
			std::cout << "Nauc se cist matlo!... :(" << endl;
		}

		for (p = 0; p < (delka * sirka); p++)
		{
			cout << " Tah hrace: " << reprezentace(aktivni_hrac) << endl;
			cout << "Ktery si rika: " << prezdivka[aktivni_hrac] << endl;
			std::cout << endl;

			vypsanipole();

			zmenapole();
									
			std::cout << endl;

			if (Vitez() == 'X')
			{
				std::cout << "Vitezem je hrac: 'X' " << ", ktery si rika: " << prezdivka1 << endl;
				std::cout << "Chces se zapsat do historie?:[a/n]" << endl;
				std::cin >> volba1;

				if (volba1[0] == 'a')
				{
					f = fopen("Historie vitezu.txt", "w");
					fprintf(f, "Vitezem je:  %s", prezdivka1);
					fprintf(f, "\n");
					fclose(f);
					break;
				}

				else
				{
					break;
				}
			}

			else if (Vitez() == 'O')
			{
				std::cout << "Vitezem je hrac: 'O' " << ", ktery si rika: " << prezdivka2 << endl;
				std::cout << "Chces se zapsat do historie?:" << endl;
				std::cin >> volba1;

				if (volba1[0] == 'a')
				{
					f = fopen("Historie vitezu.txt", "w");
					fprintf(f, "Vitezem je:  %s", prezdivka2);
					fprintf(f, "\n");
					fclose(f);
					break;
				}

				else
				{
					break;
				}
			}

			zmenahrace();

	    	if (p == delka)
			{
				system("cls");
			}

			if (p == ((delka * sirka) - 1))
			{
				std::cout << "REMIZA" << endl;
				break;
			}
		}
	}

	else if (uvitaciobrazovka() == 2)
	{
		std::cout << "KONEC!" << endl;
	}

	return 0;
}
