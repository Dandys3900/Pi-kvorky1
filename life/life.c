////////////////////////////////////////////////////////////////////////////////////////////////////////
//FileName: main.c                                                                                  //
//FileType: Visual C# Source file                                                                     //
//Size : 6kB                                                                                          //
//Author : Tomas Daniel                                                                               //
//Created On : 29/02/2020 20:15:42 AM                                                                 //
//Last Modified On : 30/08/2020 18:42:38 PM                                                           //
//Description : Program that simulates Conway´s "Game of Life"                                        //
//Creative Commons license CC                                                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <windows.h>
#include <conio.h>
#include "stdbool.h"

typedef struct
{
    char volba[3];
    char command[10];
} barevne_schema_tabulka;

void zarovnani(char text[], int velikost_obrazovky, int a_n, int hvezdy)
{
    int i = 0;
    while (text[i] != '\0') i++;

    for (int j = 0; (j < ((velikost_obrazovky - i) / 2)); j++)
        printf(" ");

    if (a_n == 1) printf("%s \n", text);
    else if (a_n == 0) printf("%s", text);

    if (hvezdy == 1)
    {
        for (int j = 0; j < (velikost_obrazovky + 7); j++)
            printf("*");
        printf("\n");
    }
}

void vypsani_hlavicky_programu(int velikost_obrazovky)
{
    zarovnani("GAME OF LIFE [beta version]", velikost_obrazovky, 1, 0);
    zarovnani("", velikost_obrazovky, 1, 1);
}

void provedeni_commandu(FILE* barevna_tabulka, char volba[3])
{
    int i = 0;
    barevne_schema_tabulka tabulka[26];
    rewind(barevna_tabulka);

    while(fscanf(barevna_tabulka, "%3s %10s", &tabulka[i].volba, &tabulka[i].command) == 2)
    {
        if(strcmp(volba, tabulka[i].volba) == 0)
        {
            tabulka[i].command[6] = ' ';
            system(tabulka[i].command);
            break;
        }

        i++;
    }
}

bool BarevneSchema(FILE* barevna_tabulka, char *barevna_volba[3])
{
    int volba_nahledu = 0;
    char volba[3];

    rewind(barevna_tabulka);

    system("cls");
    vypsani_hlavicky_programu(113);
    zarovnani(" Background color:               Text color:", 113, 1, 0);
    zarovnani("   ->a Pink                        ->1 Black", 113, 1, 0);
    zarovnani("  ->b Turquoise                   ->2 Blue", 113, 1, 0);
    zarovnani("   ->c Light red                   ->3 Green", 113, 1, 0);
    zarovnani(" ->d Light yellow                ->4 Red", 113, 1, 0);
    zarovnani("         ->e Light white                 ->5 Light blue \n", 113, 1, 0);
    zarovnani("=> Please select [f.e. 'e1']: ", 113, 0, 0);
    scanf("%s", volba);
    strcpy(barevna_volba, volba);

    provedeni_commandu(barevna_tabulka, volba);

    system("cls");
    zarovnani("That is how your color combination is looking", 113, 1, 1);
    zarovnani("-> 1 Let it as it is and proceed", 113, 1, 0);
    zarovnani("-> 2 Set default colot combination and proceed", 113, 1, 0);
    zarovnani("-> 3 Select new color combination \n", 113, 1, 0);
    zarovnani(" => Your choose: ", 113, 0, 0);
    scanf("%d", &volba_nahledu);

    switch(volba_nahledu)
    {
        case 1:
            return true;
            break;
        case 2:
            system("color 0f");
            return false;
            break;
        case 3:
            system("cls");
            BarevneSchema(barevna_tabulka, barevna_volba);
            break;
        default:
            break;
    }

    system("cls");
}

void zpozdeni(float pocet_sekund)
{
    //prevod casu na milisekundy
    float mili_sec = 1000 * pocet_sekund;
    clock_t poc_cas = clock();
    while (clock() < poc_cas + mili_sec)
        ;
}

void velikost_pole(int velikost_obrazovky, unsigned int *delka, unsigned int *sirka)
{
    system("cls");
    vypsani_hlavicky_programu(velikost_obrazovky);
    zarovnani("Please set field size \n", velikost_obrazovky, 1, 0);
    zarovnani("-> Length of cell field:", velikost_obrazovky, 1, 0);
    zarovnani("=> ", velikost_obrazovky, 0, 0);
    scanf(" %d", &*delka);

    system("cls");
    vypsani_hlavicky_programu(velikost_obrazovky);
    zarovnani("Please set field size \n", velikost_obrazovky, 1, 0);
    zarovnani("-> Width of cell field:", velikost_obrazovky, 1, 0);
    zarovnani("=> ", velikost_obrazovky, 0, 0);
    scanf(" %d", &*sirka);
    system("cls");
}

void nastaveni(int *velikost_obrazovky, FILE* barevna_tabulka, int *procento_zivych, char *volba, char *volba_tvorba, char *typ_obrazovky, char *barevna_volba[3], float *cas_od_uzivatele,  bool *zmena_barev, unsigned int *delka, unsigned int *sirka, bool *uz_nastaveno)
{
    system("cls");
    int menu_volba = 0;
    vypsani_hlavicky_programu(*velikost_obrazovky);

    zarovnani("o Set field creditials [press 1]", *velikost_obrazovky, 1, 0);
    zarovnani("o Set screen size [press 2]", *velikost_obrazovky, 1, 0);
    zarovnani("o Set set control of new generation borning [press 3]", *velikost_obrazovky, 1, 0);
    zarovnani("o Set creating of first generation [press 4]", *velikost_obrazovky, 1, 0);
    zarovnani("o Set color scheme [press 5]", *velikost_obrazovky, 1, 0);
    zarovnani("=> ", *velikost_obrazovky, 0, 0);
    scanf(" %d", &menu_volba);

    switch(menu_volba)
    {
        case 1:
            velikost_pole(*velikost_obrazovky, &*delka, &*sirka);
            *uz_nastaveno = true;
            break;
        case 2:
            system("cls");
            vypsani_hlavicky_programu(*velikost_obrazovky);
            zarovnani("Please choose window size: ", *velikost_obrazovky, 1, 0);
            zarovnani(" -> Full screen mode [press x]", *velikost_obrazovky, 1, 0);
            zarovnani("  -> Small window mode [press s]", *velikost_obrazovky, 1, 0);
            zarovnani("=> ", *velikost_obrazovky, 0, 0);
            scanf(" %c", &*typ_obrazovky);

            if (*typ_obrazovky == 'x')
                *velikost_obrazovky = 230;
            else if (*typ_obrazovky == 's')
                *velikost_obrazovky = 113;
            break;
        case 3:
            system("cls");
            vypsani_hlavicky_programu(*velikost_obrazovky);
            zarovnani("Select control of new generation borning \n", *velikost_obrazovky, 1, 0);
            zarovnani("-> Manually [press m]", *velikost_obrazovky, 1, 0);
            zarovnani("-> Automatically after X seconds [press u]:", *velikost_obrazovky, 1, 0);
            zarovnani("=> ", *velikost_obrazovky, 0, 0);
            scanf(" %c", &*volba);
            system("cls");

            if (*volba == 'u')
            {
                vypsani_hlavicky_programu(*velikost_obrazovky);
                zarovnani("Please select timing for new generation borning:", *velikost_obrazovky, 1, 0);
                zarovnani("=> ", *velikost_obrazovky, 0, 0);
                scanf(" %f", &*cas_od_uzivatele);
            }
            break;
        case 4:
            system("cls");
            vypsani_hlavicky_programu(*velikost_obrazovky);
            zarovnani("Creating of default (first) generation \n", *velikost_obrazovky, 1, 0);
            zarovnani("-> Randomly [press n]", *velikost_obrazovky, 1, 0);
            zarovnani("-> Percentage [press p]:", *velikost_obrazovky, 1, 0);
            zarovnani("=> ", *velikost_obrazovky, 0, 0);
            scanf(" %c", &*volba_tvorba);
            system("cls");

            if (*volba_tvorba == 'p')
            {
                vypsani_hlavicky_programu(*velikost_obrazovky);
                zarovnani("Set precentage of live cells:", *velikost_obrazovky, 1, 0);
                zarovnani("=> ", *velikost_obrazovky, 0, 0);
                scanf(" %d", &*procento_zivych);
            }
            break;
        case 5:
            *zmena_barev = BarevneSchema(barevna_tabulka, &*barevna_volba);
        default:
            break;
    }
}

void main_menu(int *velikost_obrazovky, FILE* barevna_tabulka, int *menu_volba, int *procento_zivych, char *volba, char *volba_tvorba, char *typ_obrazovky, char *barevna_volba[3], float *cas_od_uzivatele,  bool *zmena_barev, unsigned int *delka, unsigned int *sirka, bool *uz_nastaveno)
{
    vypsani_hlavicky_programu(*velikost_obrazovky);
    zarovnani("Main Menu", *velikost_obrazovky, 1, 0);
    zarovnani("o Start game [press 1]", *velikost_obrazovky, 1, 0);
    zarovnani("o Settings [press 2]", *velikost_obrazovky, 1, 0);
    zarovnani("o End game [press 3]", *velikost_obrazovky, 1, 0);

    zarovnani("=> ", *velikost_obrazovky, 0, 0);
    scanf(" %d", &*menu_volba);

    switch(*menu_volba)
    {
        case 1:
            system("cls");
            if (*uz_nastaveno == false)
                velikost_pole(*velikost_obrazovky, &*delka, &*sirka);
            if (*volba_tvorba == '0')
                *volba_tvorba = 'n';
            if (*volba == '0')
                *volba = 'm';
            break;
        case 2:
            nastaveni(&*velikost_obrazovky, barevna_tabulka, &*procento_zivych, &*volba, &*volba_tvorba, &*typ_obrazovky, &*barevna_volba, &*cas_od_uzivatele, &*zmena_barev, &*delka, &*sirka, &*uz_nastaveno);
            system("cls");
            main_menu(&*velikost_obrazovky, barevna_tabulka, &*menu_volba, &*procento_zivych, &*volba, &*volba_tvorba, &*typ_obrazovky, &*barevna_volba, &*cas_od_uzivatele, &*zmena_barev, &*delka, &*sirka, &*uz_nastaveno);
            break;
        default:
            system("cls");
            return;
    }
}

void zmena_pole(int delka, int sirka, char pole[delka][sirka], char pole1[delka][sirka])
{
    int pocet_sousedu = 0;

    for (int i = 0; i < delka; i++)
    {
        for (int j = 0; j < sirka; j++)
        {
            for (int a = (i - 1); a < (i + 2) && a >= 0 && a < delka; a++)
            {
                for (int b = (j - 1); b < (j + 2) && b >= 0 && b < sirka; b++)
                    if (pole[a][b] == '*') pocet_sousedu++;
            }

            if (pole[i][j] == '*')
                pocet_sousedu--;

            if (pole[i][j] == '*')
                pole1[i][j] = (pocet_sousedu < 2) ? '/' : (pocet_sousedu == 2) ? '*' : (pocet_sousedu == 3) ? '*' : (pocet_sousedu > 3) ? '/' : '/';
            if (pole[i][j] == '/')
                pole1[i][j] = (pocet_sousedu == 3) ? '*' : '/';

            pocet_sousedu = 0;
        }
    }
}

void color_switch(char barevna_volba[3], HANDLE hConsole, int text_pozadi)
{
    if (text_pozadi == 0)
    {
        switch(barevna_volba[1])
        {
            case '1':
                SetConsoleTextAttribute(hConsole, 10); //black
                break;
            case '2':
                SetConsoleTextAttribute(hConsole, 144); //blue
                break;
            case '3':
                SetConsoleTextAttribute(hConsole, 160); //green
                break;
            case '4':
                SetConsoleTextAttribute(hConsole, 192); //red
                break;
            case '5':
                SetConsoleTextAttribute(hConsole, 50); //light blue
                break;
            default:
                break;
        }
    }
    else if (text_pozadi == 1)
    {
        switch(barevna_volba[0])
        {
            case 'a':
                SetConsoleTextAttribute(hConsole, 208); //pink
                break;
            case 'b':
                SetConsoleTextAttribute(hConsole, 176); //turquoise
                break;
            case 'c':
                SetConsoleTextAttribute(hConsole, 192); //(light) red
                break;
            case 'd':
                SetConsoleTextAttribute(hConsole, 224); //(light) yellow
                break;
            case 'e':
                SetConsoleTextAttribute(hConsole, 240); //(light) white
                break;
            default:
                SetConsoleTextAttribute(hConsole, 10); //black
                break;
        }
    }
}

void vypis(int delka, int sirka, char pole[delka][sirka], char pole1[delka][sirka], int p, HANDLE hConsole, bool zmena_barev, char barevna_volba[3])
{
    system("cls");
    printf("\n");

    for (int t = 0; t < delka; t++)
    {
        for (int h = 0; h < sirka; h++)
        {
            pole[t][h] = (p != 0) ? pole1[t][h] : pole[t][h];

            if (pole[t][h] == '*')
            {
                if (zmena_barev == false)
                    SetConsoleTextAttribute(hConsole, 170);
                else
                    color_switch(barevna_volba, hConsole, 0);
                printf("  ");
            }

            if (pole[t][h] == '/')
            {
                if (zmena_barev == false)
                    SetConsoleTextAttribute(hConsole, 7);
                else
                    color_switch(barevna_volba, hConsole, 1);
                printf("  ");
            }

            color_switch(barevna_volba, hConsole, 1);
            printf("  ");
        }

        printf("\n");
        printf("\n");
    }
}

int main()
{
    unsigned int delka = 0;
    unsigned int sirka = 0;
    unsigned int p = 0;
    unsigned int menu_volba = 0;
    int rand_cisla = 0;
    int procento_zivych = 0;
    int velikost_obrazovky = 113;
    int klavesa = 0;
    char volba = '0';
    char volba_tvorba = '0';
    char typ_obrazovky = '0';
    char konec_hry = 'a';
    char barevna_volba[3];
    float cas_od_uzivatele = 0.0;
    bool zmena_barev = false;
    bool uz_nastaveno = false;

    FILE* barevna_tabulka;
    barevna_tabulka = fopen("barevna_tabulka.txt", "r");
    if (!barevna_tabulka)
        return 1;

    srand(time(NULL));
    HANDLE hConsole;

    while (konec_hry != 'n')
    {
        main_menu(&velikost_obrazovky, barevna_tabulka, &menu_volba, &procento_zivych, &volba, &volba_tvorba, &typ_obrazovky, &barevna_volba, &cas_od_uzivatele, &zmena_barev, &delka, &sirka, &uz_nastaveno);
        klavesa = 0;
        p = 0;

        char pole[delka][sirka];
        char pole1[delka][sirka];

        hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

        for (int i = 0; i < delka; i++)
        {
            for (int a = 0; a < sirka; a++)
            {
                if (volba_tvorba == 'n')
                {
                    rand_cisla = rand() % 2;

                    if (rand_cisla == 0)
                        pole[i][a] = '/'; //mrtva
                    if (rand_cisla == 1)
                        pole[i][a] = '*'; //ziva
                }

                if (volba_tvorba == 'p')
                {
                    rand_cisla = rand() % 100 + 1;

                    if (rand_cisla <= procento_zivych)
                        pole[i][a] = '*';
                    else if (rand_cisla > procento_zivych)
                        pole[i][a] = '/';
                }
            }
        }

        if (volba == 'm')
        {
            while (klavesa != 27) //27 je ASCII kod pro klavesu ESC
            {
                zmena_pole(delka, sirka, pole, pole1);
                vypis(delka, sirka, pole, pole1, p, hConsole, zmena_barev, barevna_volba);

                zarovnani("", velikost_obrazovky, 1, 1);
                zarovnani("Generation number: ", velikost_obrazovky, 0, 0);
                printf("%d \n", p);
                zarovnani("For continuing press any button for end press ESC", velikost_obrazovky, 1, 0);
                klavesa = getch();

                p++;
            }

            system("color 0f");
        }
        else if (volba == 'u')
        {
            while (1)
            {
                zpozdeni(cas_od_uzivatele);

                zmena_pole(delka, sirka, pole, pole1);
                vypis(delka, sirka, pole, pole1, p, hConsole, zmena_barev, barevna_volba);

                zarovnani("", velikost_obrazovky, 1, 1);
                zarovnani("Generation number: ", velikost_obrazovky, 0, 0);
                printf("%d \n", p);
                zarovnani("For end press CTRL+C", velikost_obrazovky, 1, 0);

                p++;
            }
        }

        zarovnani("", velikost_obrazovky, 1, 1);
        zarovnani("Thanks for play!, would you like to play again?", velikost_obrazovky, 1, 0);
        zarovnani("YES! [press a]", velikost_obrazovky, 1, 0);
        zarovnani("NO! [press n]", velikost_obrazovky, 1, 0);
        zarovnani("=> ", velikost_obrazovky, 0, 0);
        scanf(" %c", &konec_hry);
        system("cls");
    }

    fclose(barevna_tabulka);
    return 0;
}
