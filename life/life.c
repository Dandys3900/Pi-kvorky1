////////////////////////////////////////////////////////////////////////////////////////////////////////
//FileName: hra_zivota_main.c
//FileType: Visual C# Source file
//Size : 6kB
//Author : Tomas Daniel
//Created On : 10/03/2020 21:45:42 AM
//Last Modified On : 04/03/2020 21:45:18 PM
//Description : Program that simulates Conway´s "Game of Life"
//Creative Commons license CC
////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <windows.h>

void zarovnani(char text[], int velikost_obrazovky, int a_n, int hvezdy)
{
    int i = 0;
    int j = 0;

    while(text[i] != '\0') i++;

    for(j = 0; (j < ((velikost_obrazovky - i) / 2)); j++) printf(" ");

    if(a_n == 1) printf("%s \n", text);
    else if(a_n == 0) printf("%s", text);

    if(hvezdy == 1)
    {
        for(j = 0; j < (velikost_obrazovky + 7); j++) printf("*");
        printf("\n");
    }
}

void zpozdeni(float pocet_sekund)
{
    // prevod casu na milisekundy
    float mili_sec = 1000 * pocet_sekund;

    // ulozeny pocatecniho casu
    clock_t poc_cas = clock();

    // delam dokud se neukonci for-cyklus
    while (clock() < poc_cas + mili_sec)
        ;
}

void zmena_pole(int delka, int sirka, char pole[delka][sirka], char pole1[delka][sirka])
{
    int pocet_sousedu = 0;

   for(int i = 0; i < delka; i++)
   {
       for(int j = 0; j < sirka; j++)
       {
           for(int a = (i - 1); a < (i + 2) && a >= 0 && a < delka; a++)
           {
               for(int b = (j - 1); b < (j + 2) && b >= 0 && b < sirka; b++)
               {
                   if(pole[a][b] == '*') pocet_sousedu++;
               }
           }

           if(pole[i][j] == '*') pocet_sousedu--; 

           if(pole[i][j] == '*') pole1[i][j] = (pocet_sousedu < 2) ? '/' : (pocet_sousedu == 2) ? '*' : (pocet_sousedu == 3) ? '*' : (pocet_sousedu > 3) ? '/' : '/';
           if(pole[i][j] == '/') pole1[i][j] = (pocet_sousedu == 3) ? '*' : '/';

           pocet_sousedu = 0;
       }
   }

    pocet_sousedu = 0;
}

void vypis(int delka, int sirka, char pole[delka][sirka], char pole1[delka][sirka], int p, HANDLE hConsole)
{
    system("cls");

    for(int t = 0; t < delka; t++)
    {
        for(int h = 0; h < sirka; h++)
        {
            if(p != 0)
            {
                pole[t][h] = pole1[t][h];
                pole1[t][h] = ' ';

                if(pole[t][h] == '*')
                {
                    SetConsoleTextAttribute(hConsole, 170);
                    printf("  ");
                }

                if(pole[t][h] == '/')
                {
                    SetConsoleTextAttribute(hConsole, 7);
                    printf("  ");
                }

                SetConsoleTextAttribute(hConsole, 7);
                printf("  ");
            }

            else if(p == 0)
            {
                if(pole[t][h] == '*')
                {
                    SetConsoleTextAttribute(hConsole, 170);
                    printf("  ");
                }

                if(pole[t][h] == '/')
                {
                    SetConsoleTextAttribute(hConsole, 7);
                    printf("  ");
                }

                SetConsoleTextAttribute(hConsole, 7);
                printf("  ");
            }
        }

        printf("\n");
        SetConsoleTextAttribute(hConsole, 7);
        printf("\n");
    }

    printf("Cislo generace: %d \n", p);
    p++;
}

int main()
{
    unsigned int delka = 0;
    unsigned int sirka = 0;
    unsigned int p = 0;
    int rand_cisla = 0;
    int procento_zivych = 0;
    int velikost_obrazovky = 0;
    char nacteny_znak = '0';
    char volba = '0';
    char volba_tvorba = '0';
    char typ_obrazovky = '0';
    char konec_hry = 'a';
    float cas_od_uzivatele = 0; //cas ktery zada uzivatel

    srand(time(NULL));

    HANDLE hConsole;

    while(konec_hry != 'n')
    {
        printf("Vyber si v jake velikosti okna budes hrat: \n");
        printf("   Full screen mode[stikni x] \n");
        printf("   Small window mode[stikni s] \n");
        scanf(" %c", &typ_obrazovky);

        if(typ_obrazovky == 'x') velikost_obrazovky = 230;
        else if(typ_obrazovky == 's') velikost_obrazovky = 100;

        system("cls");

        zarovnani("! PRO VAS MAXIMALNI KOMFORT NEMENTE PROSIM VELIKOST VASEHO OKNA BEHEM CHODU PROGRAMU !", velikost_obrazovky, 1, 1);
        zpozdeni(4.5);

        system("cls");

        zarovnani("VITEJTE VE HRE ZIVOTA, [beta verze]", velikost_obrazovky, 1, 0);
        zarovnani("", velikost_obrazovky, 1, 1);

        zarovnani("Nastav velikost pole", velikost_obrazovky, 1, 0);
        printf("\n");
        zarovnani("Sirka bunecneho pole:", velikost_obrazovky, 1, 0);
        zarovnani("-> ", velikost_obrazovky, 0, 0);
        scanf(" %d", &delka);

        system("cls");

        zarovnani("VITEJTE VE HRE ZIVOTA, [beta verze]", velikost_obrazovky, 1, 0);
        zarovnani("", velikost_obrazovky, 1, 1);

        zarovnani("Nastav velikost pole", velikost_obrazovky, 1, 0);
        printf("\n");
        zarovnani("Vyska bunecneho pole:", velikost_obrazovky, 1, 0);
        zarovnani("-> ", velikost_obrazovky, 0, 0);
        scanf(" %d", &sirka);

        system("cls");

        zarovnani("VITEJTE VE HRE ZIVOTA, [beta verze]", velikost_obrazovky, 1, 0);
        zarovnani("", velikost_obrazovky, 1, 1);

        zarovnani("Ovladani vzniku novych generaci", velikost_obrazovky, 1, 0);
        printf("\n");
        zarovnani("Manualne[stikni m]", velikost_obrazovky, 1, 0);
        zarovnani("Automaticky po x sekundach[stiskni u]:", velikost_obrazovky, 1, 0);
        zarovnani("-> ", velikost_obrazovky, 0, 0);
        scanf(" %c", &volba);

        system("cls");

        if(volba == 'u')
        {
            zarovnani("VITEJTE VE HRE ZIVOTA, [beta verze]", velikost_obrazovky, 1, 0);
            zarovnani("", velikost_obrazovky, 1, 1);

            zarovnani("Nastav si prosim, po kolika sekundach se zrodi nova generace:", velikost_obrazovky, 1, 0);
            zarovnani("-> ", velikost_obrazovky, 0, 0);
            scanf(" %f", &cas_od_uzivatele);

            system("cls");
        }

        zarovnani("VITEJTE VE HRE ZIVOTA, [beta verze]", velikost_obrazovky, 1, 0);
        zarovnani("", velikost_obrazovky, 1, 1);

        zarovnani("Tvorba (uvodni) nulte generace", velikost_obrazovky, 1, 0);
        printf("\n");
        zarovnani("Nahodne[stikni n]", velikost_obrazovky, 1, 0);
        zarovnani("Procentualni zastoupeni[stikni p]:", velikost_obrazovky, 1, 0);
        zarovnani("-> ", velikost_obrazovky, 0, 0);
        scanf(" %c", &volba_tvorba);

        system("cls");

        if(volba_tvorba == 'p')
        {
            zarovnani("VITEJTE VE HRE ZIVOTA, [beta verze]", velikost_obrazovky, 1, 0);
            zarovnani("", velikost_obrazovky, 1, 1);

            zarovnani("Nastav procento zivych:", velikost_obrazovky, 1, 0);
            zarovnani("-> ", velikost_obrazovky, 0, 0);
            scanf("%d", &procento_zivych);

            system("cls");
        }

        char pole[delka][sirka];
        char pole1[delka][sirka];

        hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

        for(int i = 0; i < delka; i++)
        {
            for(int a = 0; a < sirka; a++)
            {
                if(volba_tvorba == 'n')
                {
                    rand_cisla = rand()%2;

                    if(rand_cisla == 0) pole[i][a] = '/'; // jako dead ;)
                    if(rand_cisla == 1) pole[i][a] = '*'; // jako alive ;)
                }

                if(volba_tvorba == 'p')
                {
                    rand_cisla = rand()%100 + 1;

                    if(rand_cisla <= procento_zivych) pole[i][a] = '*';
                    else if(rand_cisla > procento_zivych) pole[i][a] = '/';
                }
            }
        }

        nacteny_znak = 'n';

        if(volba == 'm')
        {
            while(nacteny_znak != 'a')
            {
                zmena_pole(delka, sirka, pole, pole1);
                vypis(delka, sirka, pole, pole1, p, hConsole);

                p++;

                printf("Chcete ukoncit hru? [a/n] \n");
                scanf(" %1c", &nacteny_znak);
            }
        }

        else if(volba == 'u')
        {
            while(1)
            {
                zpozdeni(cas_od_uzivatele);

                zmena_pole(delka, sirka, pole, pole1);
                vypis(delka, sirka, pole, pole1, p, hConsole);

                p++;

                printf("Konec programu [Ctrl + c] \n");
            }
        }

        zarovnani("", velikost_obrazovky, 1, 1);
        zarovnani("DIKY ZA SPUSTENI!, chces si zahrat znova?", velikost_obrazovky, 1, 0);
        zarovnani("Ano! [stikni a]", velikost_obrazovky, 1, 0);
        zarovnani("Ne, diky! [stiskni n]", velikost_obrazovky, 1, 0);
        zarovnani("-> ", velikost_obrazovky, 0, 0);
        scanf(" %c", &konec_hry);

        system("cls");
    }

    return 0;
}
