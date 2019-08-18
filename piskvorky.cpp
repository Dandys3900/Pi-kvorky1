#include <iostream>

using namespace std;
char pole[3][3] = { '1', '2', '3', '4', '5', '6', '7', '8', '9' };
char hrac = 'X';
char prezdivka1[25];
char prezdivka2[25];

void vypsanipole()
{
    for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 3; j++)
		{
			std::cout << pole[i][j] << " ";
		}
		std::cout << endl;
	}
}

void zmenapole()
{
	int volbahrace = 0;

	std::cout << "Kam chces hrat ted?: " << endl;
	std::cin >> volbahrace;

	while (volbahrace > 9)
	{
		std::cout << " Spatna volba - znova: " << endl;
		std::cin >> volbahrace;
	}

	if (volbahrace == 1)
	{
		if (pole[0][0] == '1')
		{
			pole[0][0] = hrac;
		}
		
		else
		{
			std::cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
			std::cout << endl;
		}
	}

	else if (volbahrace == 2)
	{
		if (pole[0][1] == '2')
		{
			pole[0][1] = hrac;
		}

		else
		{
			std::cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
			std::cout << endl;
		}
	}

	else if (volbahrace == 3)
	{
		if (pole[0][2] == '3')
		{
			pole[0][2] = hrac;
		}

		else
		{
			std::cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
			std::cout << endl;
		}
	}

	else if (volbahrace == 4)
	{
		if (pole[1][0] == '4')
		{
			pole[1][0] = hrac;
		}

		else
		{
			std::cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
			std::cout << endl;
		}
	}

	else if (volbahrace == 5)
	{
		if (pole[1][1] == '5')
		{
			pole[1][1] = hrac;
		}

		else
		{
			std::cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
			std::cout << endl;
		}
	}

	else if (volbahrace == 6)
	{
		if (pole[1][2] == '6')
		{
			pole[1][2] = hrac;
		}

		else
		{
			std::cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
			std::cout << endl;
		}
	}

	else if (volbahrace == 7)
	{
		if (pole[2][0] == '7')
		{
			pole[2][0] = hrac;
		}

		else
		{
			std::cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
			std::cout << endl;
		}
	}

	else if (volbahrace == 8)
	{
		if (pole[2][1] == '8')
		{
			pole[2][1] = hrac;
		}

		else
		{
			std::cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
			std::cout << endl;
		}
	}

	else if (volbahrace == 9)
	{
	if (pole[2][2] == '9')
	{
		pole[2][2] = hrac;
	}

	else
	{
		std::cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
		std::cout << endl;
	}

	}
}

void zmenahrace()
{
	if (hrac == 'O')
	{
		hrac = 'X';
	}

	else 
	{
		hrac = 'O';
	}
}

char Vitez()
{
	int ukazatelX = 0;
	int ukazatelO = 0;
	//musím si vytvořit samostatnou proměnou na sloupce, protože jinak kdyby byly pod sebou např. xxx tak by ten ukazatelX nabil hodnoty 4...
	int ukazatelXsloupce = 0;
	int ukazatelOsloupce = 0;

	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 3; j++)
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

		if ((ukazatelX == 3) || (ukazatelXsloupce == 3))
		{
			return 'X';
		}

		else if ((ukazatelO == 3) || (ukazatelOsloupce == 3))
		{
			return 'O';
		}
				
		//Vím, že se tahle podmínka(pod tímto textem :)) bude provádět pokaždé, ale když ji dám ven z cyklu, tak to blbe...
		else if ((pole[0][0] == 'X' && pole[1][1] == 'X' && pole[2][2] == 'X') || (pole[0][2] == 'X' && pole[1][1] == 'X' && pole[2][0] == 'X'))
		{
			return 'X';
		}

		else if ((pole[0][0] == 'O' && pole[1][1] == 'O' && pole[2][2] == 'O') || (pole[0][2] == 'O' && pole[1][1] == 'O' && pole[2][0] == 'O'))
		{
			return 'O';
		}

		ukazatelX = 0;
		ukazatelO = 0;
		ukazatelXsloupce = 0;
		ukazatelOsloupce = 0;
	}
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

int main()
{
	int p = 0;
		
	if (uvitaciobrazovka() == 1)
	{
		int volba = 0;

		std::cout << " Zacina hrac X ... 1" << endl;
		std::cout << " Zacina hrac O ... 2" << endl;
		std::cout << endl;

		std::cout << "Kdo zacne?: " << endl;
		std::cin >> volba;

		if (volba == 1)
		{
			std::cout << " Hrac X si vybere prezdivku: " << endl;
			std::cin >> prezdivka1;

			std::cout << " Hrac O si vybere prezdivku: " << endl;
			std::cin >> prezdivka2;
		}

		if (volba == 2)
		{
			std::cout << " Hrac O si vybere prezdivku: " << endl;
			std::cin >> prezdivka2;

			std::cout << " Hrac X si vybere prezdivku: " << endl;
			std::cin >> prezdivka1;
		}

		if (volba == 1)
		{
			hrac = 'X';
		}

		else if (volba == 2)
		{
			hrac = 'O';
		}

		else if (volba > 2)
		{
			std::cout << "Nauc se cist matlo!... :(" << endl;
		}

		for (p = 0; p < 10; p++)
		{
			std::cout << " Tah hrace: " << hrac;
			std::cout << endl;

			zmenaprezdivky();
			std::cout << endl;

			vypsanipole();

			zmenapole();
			
			vypsanipole();

			std::cout << endl;
			if (Vitez() == 'X')
			{
				std::cout << "Vitezem je hrac: 'X' " << ", ktery si rika: " << prezdivka1 << endl;
				break;
			}

			else if (Vitez() == 'O')
			{
				std::cout << "Vitezem je hrac: 'O' " << ", ktery si rika: " << prezdivka2 << endl;
				break;
			}

			zmenahrace();

			if (p == 4)
			{
				system("cls");
			}

			if (p == 8)
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
