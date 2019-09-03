#include <iostream>
#include <string>

using namespace std;

enum strany {NONE, O, X};
strany pole[3][3];
strany aktivni_hrac = X;
string prezdivka[X+1];


char reprezentace(strany a)
{
	return a == X ? 'X': a == O ? 'O' : ' ';
}

void vypis_pole()
{
    for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 3; j++)
		{
			char out;
			if (pole[i][j] == NONE)
				out = '1' + i*3 + j;
			else
				out = reprezentace(pole[i][j]);
			cout << out << " | ";
		}
		cout << endl;
	}
}

void obsad_policko()
{
	int volbahrace = 5;

	cout << "Kam chces hrat ted?: " << endl;
	cin >> volbahrace;

	while (volbahrace > 9 || volbahrace < 1)
	{
		cout << " Spatna volba - znova: " << endl;
		cin >> volbahrace;
	}

	int i = (volbahrace-1) / 3;
	int j = (volbahrace-1) % 3;

	if (pole[i][j] != NONE) {
		cout << "pole je jiz OBSAZENE!, smula prisel jsi o tah NAUC SE PRAVIDLA blbecku!" << endl;
		cout << endl;
	} else
		pole[i][j] = aktivni_hrac;
}

void zmen_hrace()
{
	aktivni_hrac = (aktivni_hrac == O) ? X : O;
}

strany kdo_je_vitez()
{
	for (int i = 0; i < 3; i++) {
		// radky
		if (pole[i][0] && pole[i][0] == pole[i][1] && pole[i][1] == pole[i][2])
			return pole[i][0];
		// sloupce
		if (pole[0][i] && pole[0][i] == pole[1][i] && pole[1][i] == pole[2][i])
			return pole[0][i];
	}
	if (pole[1][1]) {
		// zkontroluju diagonaly
		if (pole[0][0] == pole[1][1] && pole[1][1] == pole[2][2])
			return pole[1][1];
		if (pole[2][0] == pole[1][1] && pole[1][1] == pole[0][2])
			return pole[1][1];
	}
	return NONE;
}

int uvitaci_obrazovka()
{
	int moznost = 2;

	cout << "VITEJTE VE HRE PISKVORKY" << endl;
	cout << "Co ted?: " << endl;
	cout << endl;

	cout << "Zacit hrat...1" << endl;
	cout << "Ukoncit program...2" << endl;
	cin >> moznost;

	return moznost == 1;
}

int main()
{
	int p = 0;

	if (uvitaci_obrazovka())
	{
		int volba = 0;

		cout << " Zacina aktivni_hrac X ... 1" << endl;
		cout << " Zacina aktivni_hrac O ... 2" << endl;
		cout << endl;

		cout << "Kdo zacne?: " << endl;
		cin >> volba;

		aktivni_hrac = (volba == 1) ? X : O;

		for (int i =0; i < 2; i++) {
			cout << "Hrac " << reprezentace(aktivni_hrac) << " si vybere prezdivku: " << endl;
			cin >> prezdivka[aktivni_hrac];
			zmen_hrace();
		}

		if (volba > 2)
			cout << "Nauc se cist matlo!... :(" << endl;

		for (p = 0; p < 10; p++)
		{
			cout << " Tah hrace: " << reprezentace(aktivni_hrac) << endl;
			cout << "Ktery si rika: " << prezdivka[aktivni_hrac] << endl;
			cout << endl;

			vypis_pole();

			obsad_policko();

			vypis_pole();
			cout << endl;

			strany vitez = kdo_je_vitez();
			if (vitez != NONE) {
				cout << "Vitezem je aktivni_hrac: " << reprezentace(vitez) << " , ktery si rika: " << prezdivka[vitez] << endl;
				break;
			}

			zmen_hrace();

			if (p == 8)
			{
				cout << "REMIZA" << endl;
				break;
			}
		}
	}
	else
	{
		cout << "KONEC!" << endl;
	}

	return 0;
}
