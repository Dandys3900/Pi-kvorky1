////////////////////////////////////////////////////////////////////////////////////////////////////////
//FileName: hra_zivota_main.c
//FileType: Visual C# Source file
//Size : 6kB
//Author : Tomas Daniel
//Created On : 29/02/2020 10:20:42 AM
//Last Modified On : 04/03/2020 21:45:18 PM
//Description : Program that simulates Conway´s "Game of Life"
//Creative Commons license CC
////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h> // sleep

void zpozdeni(float pocet_sekund)
{
	sleep(pocet_sekund);
}

void zmena_pole(int delka, int sirka, char pole[delka][sirka], char pole1[delka][sirka])
{
    int sum_x = 0;
    int sum_y = 0;
    int pocet_sousedu = 0;

    for(int i = 0; i < delka; i++)
    {
        for(int j = 0; j < sirka; j++)
        {
            //na stejnem radku
            sum_x = i;
            sum_y = j + 1;

            if(sum_x >= 0 && sum_x < delka && sum_y >= 0 && sum_y < sirka)
            {
                if(pole[i][j + 1] == '*') pocet_sousedu++;
            }

            sum_x = i;
            sum_y = j - 1;

            if(sum_x >= 0 && sum_x < delka && sum_y >= 0 && sum_y < sirka)
            {
                if(pole[i][j - 1] == '*') pocet_sousedu++;
            }

            //na vyssim radku
            sum_x = i - 1;
            sum_y = j;

            if(sum_x >= 0 && sum_x < delka && sum_y >= 0 && sum_y < sirka)
            {
                if(pole[i - 1][j] == '*') pocet_sousedu++;
            }

            sum_x = i - 1;
            sum_y = j - 1;

            if(sum_x >= 0 && sum_x < delka && sum_y >= 0 && sum_y < sirka)
            {
                if(pole[i - 1][j - 1] == '*') pocet_sousedu++;
            }

            sum_x = i - 1;
            sum_y = j + 1;

            if(sum_x >= 0 && sum_x < delka && sum_y >= 0 && sum_y < sirka)
            {
                if(pole[i - 1][j + 1] == '*') pocet_sousedu++;
            }

            //na nizsim radku
            sum_x = i + 1;
            sum_y = j;

            if(sum_x >= 0 && sum_x < delka && sum_y >= 0 && sum_y < sirka)
            {
                if(pole[i + 1][j] == '*') pocet_sousedu++;
            }

            sum_x = i + 1;
            sum_y = j - 1;

            if(sum_x >= 0 && sum_x < delka && sum_y >= 0 && sum_y < sirka)
            {
                if(pole[i + 1][j - 1] == '*') pocet_sousedu++;
            }

            sum_x = i + 1;
            sum_y = j + 1;

            if(sum_x >= 0 && sum_x < delka && sum_y >= 0 && sum_y < sirka)
            {
                if(pole[i + 1][j + 1] == '*') pocet_sousedu++;
            }

            if(pole[i][j] == '*')
            {
                pole1[i][j] = (pocet_sousedu < 2) ? '/' : (pocet_sousedu == 2) ? '*' : (pocet_sousedu == 3) ? '*' : (pocet_sousedu > 3) ? '/' : '/'; //vytvarim si paralelne druhe pole, tak aby dalsi bunky v poradi nebyly ovlivneny zmenou v jejich poli
            }

            if(pole[i][j] == '/')
            {
                pole1[i][j] = (pocet_sousedu == 3) ? '*' : '/';
            }

            pocet_sousedu = 0;
        }
    }
}

void vypis(int delka, int sirka, char pole[delka][sirka], char pole1[delka][sirka], char volba, int p)
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
                    printf("**");
                }

                if(pole[t][h] == '/')
                {
                    printf("  ");
                } 

                printf("  ");
            }
            
            else if(p == 0)
            {
                if(pole[t][h] == '*')
                {
                    printf("**");
                }

                if(pole[t][h] == '/')
                {
                    printf("  ");
                }

                printf("  ");
            }         
        }

        printf("\n");
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
    char nacteny_znak = '0';
    char volba = '0';
    char volba_tvorba = '0';
    float cas_od_uzivatele = 0; //cas ktery zada uzivatel

    srand(time(NULL));

    printf("VITEJTE VE HRE ZIVOTA, [beta verze] \n");
    printf("\n");

    printf("Nastav velikost pole: \n");
    printf("   Delka: (souradnice X) \n");
    scanf("%d", &delka);
    printf("   Sirka: (souradnice Y) \n");
    scanf("%d", &sirka);

    printf("\n");

    printf("Jak chcete ovladat vznik novych generaci?: \n");
    printf("   Manualne[stikni m] \n");
    printf("   Automaticky po x sekundach[stiskni u] \n");
    scanf(" %1c", &volba);

    if(volba == 'u')
    {
        printf("   Nastav si prosim, po kolika sekundach se zrodi nova generace: \n");
        scanf("%f", &cas_od_uzivatele);
    }

    printf("\n");

    printf("Jak chcete vytvorit nultou (uvodni) generaci? \n");
    printf("   Nahodne[stikni n] \n");
    printf("   Procentualni zastoupeni[stikni p] \n");
    scanf(" %1c", &volba_tvorba);

    if(volba_tvorba == 'p')
    {
        printf("   Nastav procento zivych: \n");
        scanf("%d", &procento_zivych);
        printf("Procento mrtvych redy bude: %d procent \n", (100 - procento_zivych));
        zpozdeni(1.5);
    }

    printf("\n");    

    char pole[delka][sirka];
    char pole1[delka][sirka];

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
            vypis(delka, sirka, pole, pole1, volba, p);
            
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
            vypis(delka, sirka, pole, pole1, volba, p);

            p++;

            printf("Pro konec programu stisknete klavesu stisknete [Ctrl + c] \n");
        }
    }

    return 0;
}
