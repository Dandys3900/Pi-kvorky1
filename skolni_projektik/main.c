#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

typedef struct
{
    int id_nemoci;
    char nazev_nemoci[100];
    int pocet_umrti;
    float procento_mrtvych;
} nemoc;

typedef struct
{
    int id_nemoci;
    char priznaky_nemoci[1000];
} nemoc_priznaky;

typedef struct
{
    int id_nemoci;
    char popis_nemoci[1000];
} nemoc_popis;

int PocetNemoci(FILE* seznam_nemoci)
{
    int pocet_nemoci = 0;
    nemoc x;

    while(fscanf(seznam_nemoci,"%d %49s %d %f", &x.id_nemoci, &x.nazev_nemoci, &x.pocet_umrti, &x.procento_mrtvych) == 4) pocet_nemoci++;
    return pocet_nemoci;
}

int menu()
{
    int volba = 0;

    printf("1 Vypis vsech nemoci \n");
    printf("2 Vypis priznaku a zakladnich informaci dane nemoci \n");
    printf("3 Vypis popisu dane nemoci \n");
    printf("4 Vypis vseho o konkretni nemoci \n");
    printf("5 Hledani konkretni nemoci \n");
    printf("6 Razeni nemoci podle ruznych kriterii \n");
    printf("7 Upravit zaznam o konkretni nemoci \n");
    printf("8 Pridej novou nemoc \n");
    printf("9 Smazani konkretni nemoci \n");
    printf("10 Urceni nemoci pomoci Vasich priznaku \n \n");

    printf("Zadej tvou volbu 1-10 (jinak konec): ");
    scanf("%d",&volba);

    return volba;
}

void VypisNemoci(FILE *seznam_nemoci)
{
    nemoc x;

    while(fscanf(seznam_nemoci,"%d %49s %d %f", &x.id_nemoci, &x.nazev_nemoci, &x.pocet_umrti, &x.procento_mrtvych) == 4) printf("-> %d %s \n", x.id_nemoci, x.nazev_nemoci);

    rewind(seznam_nemoci);
}

void OhranicenyVypis()
{
    for(int i = 0; i < 115; i++) printf("-");
    printf("\n");
}

void NactenidoPole_Vypis(FILE* seznam_nemoci, nemoc pole[], int volba)
{
    int i = 0;
    int pocet_nemoci = PocetNemoci(seznam_nemoci);
    rewind(seznam_nemoci);

    if(volba == 0)
    {
        while(fscanf(seznam_nemoci, "%d %49s %d %f", &pole[i].id_nemoci, &pole[i].nazev_nemoci, &pole[i].pocet_umrti, &pole[i].procento_mrtvych) == 4)
        {
            printf(" Nemoc %s: \n", pole[i].nazev_nemoci);
            printf("  -> celkovy pocet umrti: %d \n", pole[i].pocet_umrti);
            printf("  -> procentualni umrtnost: %0.2f \n", pole[i].procento_mrtvych);
            OhranicenyVypis();

            i++;
        }
    }

    else if(volba == 1)
    {
        for(i = 0; i < pocet_nemoci; i++)
        {
            printf(" Nemoc %s: \n", pole[i].nazev_nemoci);
            printf("  -> celkovy pocet umrti: %d \n", pole[i].pocet_umrti);
            printf("  -> procentualni umrtnost: %0.2f \n", pole[i].procento_mrtvych);
            OhranicenyVypis();
        }
    }

    else if(volba == 2)
    {
        while(fscanf(seznam_nemoci, "%d %49s %d %f", &pole[i].id_nemoci, &pole[i].nazev_nemoci, &pole[i].pocet_umrti, &pole[i].procento_mrtvych) == 4) i++;
    }
}

void RozsirenyVypis(FILE* seznam_nemoci)
{
    nemoc y;
    rewind(seznam_nemoci);

    while(fscanf(seznam_nemoci, "%d %49s %d %f", &y.id_nemoci, &y.nazev_nemoci, &y.pocet_umrti, &y.procento_mrtvych) == 4)
    {
        printf(" Nemoc %s: \n", y.nazev_nemoci);
        printf("  -> celkovy pocet umrti: %d \n", y.pocet_umrti);
        printf("  -> procentualni umrtnost: %0.2f \n", y.procento_mrtvych);
        OhranicenyVypis();
    }
}

void NazevNemoci(FILE* seznam_nemoci, int id_nemoci)
{
    nemoc y;
    rewind(seznam_nemoci);

    while(fscanf(seznam_nemoci, "%d %49s %d %f", &y.id_nemoci, &y.nazev_nemoci, &y.pocet_umrti, &y.procento_mrtvych) == 4)
    {
        if(y.id_nemoci == id_nemoci)
        {
            y.nazev_nemoci[0] = y.nazev_nemoci[0] + 32;
            printf("Nemoc %s: \n", y.nazev_nemoci);
            break;
        }
    }
}

void VypisPriznaku(FILE* priznaky_nemoci, FILE* seznam_nemoci, int id_nemoci)
{
    nemoc_priznaky x;
    nemoc y;
    int pozice = 0;
    rewind(seznam_nemoci);

    while(fscanf(seznam_nemoci, "%d %49s %d %f", &y.id_nemoci, &y.nazev_nemoci, &y.pocet_umrti, &y.procento_mrtvych) == 4)
    {
        if(y.id_nemoci == id_nemoci)
        {
            printf("Informace o umrtnosti: \n");
            printf("  -> celkovy pocet umrti: %d \n", y.pocet_umrti);
            printf("  -> procentualni umrtnost: %0.2f \n \n", y.procento_mrtvych);
            printf("Priznaky teto nemoci jsou: \n");
            break;
        }
    }

    while(fscanf(priznaky_nemoci, "%d %999s", &x.id_nemoci, &x.priznaky_nemoci) != EOF)
    {
        if(x.id_nemoci == id_nemoci)
        {
            while(1)
            {
                if(x.priznaky_nemoci[pozice] == '.') break;
                if(x.priznaky_nemoci[pozice] == ',')
                {
                    printf("\n  -> ");
                    pozice++;
                }
                if(pozice == 0) printf("  -> %c", x.priznaky_nemoci[pozice]);
                else printf("%c", x.priznaky_nemoci[pozice]);

                pozice++;
            }

            printf("\n");
            OhranicenyVypis();
        }
    }

    rewind(seznam_nemoci);
    rewind(priznaky_nemoci);
}

void VypisPopisu(FILE* popis_nemoci, FILE* seznam_nemoci, int id_nemoci)
{
    int pozice = 0;
    nemoc_popis x;

    while(fscanf(popis_nemoci,"%d %999s", &x.id_nemoci, &x.popis_nemoci) != EOF)
    {
        if(x.id_nemoci == id_nemoci)
        {
            while(1)
            {
                if(x.popis_nemoci[pozice] == '.') break;
                if(x.popis_nemoci[pozice] == '_') printf(" ");
                else printf("%c", x.popis_nemoci[pozice]);
                if(pozice == 100 || pozice == 200 || pozice == 300) printf("\n");

                pozice++;
            }

            printf("\n");
            OhranicenyVypis();
        }
    }

    rewind(seznam_nemoci);
    rewind(popis_nemoci);
}

void VypisVseho(FILE* seznam_nemoci, FILE* priznaky_nemoci, FILE* popis_nemoci, int id_nemoci)
{
    rewind(seznam_nemoci);
    rewind(popis_nemoci);
    rewind(priznaky_nemoci);

    NazevNemoci(seznam_nemoci, id_nemoci);
    printf(" Toto je o ni v nasi databazi: \n");
    OhranicenyVypis();

    VypisPriznaku(priznaky_nemoci, seznam_nemoci, id_nemoci);
    VypisPopisu(popis_nemoci, seznam_nemoci, id_nemoci);
}

void InfooNemociMenu(FILE* seznam_nemoci, FILE* priznaky_nemoci, FILE* popis_nemoci, int id_nemoci)
{
    int volba_1 = 0;

    printf("-> Co se o ni chcete dozvedet: \n");
    printf("  -> 1 Priznaky nemoci a mortality \n");
    printf("  -> 2 Popis nemoci \n");
    printf("  -> 3 Vsechno, co je o ni v nasi databazi \n");
    printf("   -> ");
    scanf("%d", &volba_1);

    system("cls");

    switch(volba_1)
    {
        case 1:
            VypisPriznaku(priznaky_nemoci, seznam_nemoci, id_nemoci);
            break;
        case 2:
            VypisPopisu(popis_nemoci, seznam_nemoci, id_nemoci);
            break;
        case 3:
            VypisVseho(seznam_nemoci, priznaky_nemoci, popis_nemoci, id_nemoci);
            break;
        default: break;
    }
}

void HledaniNemoci(FILE* seznam_nemoci, FILE* priznaky_nemoci, FILE* popis_nemoci)
{
    nemoc x;
    char nazev_nemoci[50];
    int id_nemoci = 0;
    int volba_1 = 0;
    int pocet_obeti = 0;
    int uspech = 0;
    float procentualni_umrtnost = 0.0;

    printf("Podle ceho chcete nemoc vyhledat? \n");
    printf("-> 1 Podle jmena \n");
    printf("-> 2 Podle poctu obeti \n");
    printf("-> 3 Podle procentualiho umrti \n");

    printf("Vase volba: ");
    scanf("%d", &volba_1);
    system("cls");

    switch(volba_1)
    {
        case 1:
            printf("Zadejte nazev nemoci, kterou chcete vyhledat [viceslovne nazvy oddeluj podtrzitkem]: ");
            scanf("%49s", &nazev_nemoci);
            break;
        case 2:
            printf("Zadejte pocet obeti teto nemoci: ");
            scanf("%d", &pocet_obeti);
            break;
        case 3:
            printf("Zadejte procentualniho umrtnost teto nemoci: ");
            scanf("%f", &procentualni_umrtnost);
            break;
        default:
            break;
    }

    system("cls");

    rewind(seznam_nemoci);

    while(fscanf(seznam_nemoci, "%d %49s %d %f", &x.id_nemoci, &x.nazev_nemoci, &x.pocet_umrti, &x.procento_mrtvych) == 4)
    {
        if(strcmp(nazev_nemoci, x.nazev_nemoci) == 0)
        {
            id_nemoci = x.id_nemoci;

            printf("Shoda! s nemoci %s: \n", x.nazev_nemoci);
            InfooNemociMenu(seznam_nemoci, priznaky_nemoci, popis_nemoci, id_nemoci);
            uspech = 1;

            break;
        }

        else if(pocet_obeti == x.pocet_umrti)
        {
            id_nemoci = x.id_nemoci;

            printf("Shoda! s nemoci %s: \n", x.nazev_nemoci);
            InfooNemociMenu(seznam_nemoci, priznaky_nemoci, popis_nemoci, id_nemoci);
            uspech = 1;

            break;
        }

        else if(procentualni_umrtnost == x.procento_mrtvych)
        {
            id_nemoci = x.id_nemoci;

            printf("Shoda! s nemoci %s: \n", x.nazev_nemoci);
            InfooNemociMenu(seznam_nemoci, priznaky_nemoci, popis_nemoci, id_nemoci);
            uspech = 1;

            break;
        }
    }

    if(uspech == 0) printf("Je mi lito, ale nic jsem v nasi databazi nenasli... :( \n");
}

void RazeniNemoci(FILE* seznam_nemoci, FILE* priznaky_nemoci, FILE* popis_nemoci)
{
    int volba = 0;
    int pocet_nemoci = 0;
    nemoc y;
    nemoc pom;
    nemoc pole[1000];

    NactenidoPole_Vypis(seznam_nemoci, pole, 0);

    rewind(seznam_nemoci);
    pocet_nemoci = PocetNemoci(seznam_nemoci);
    rewind(seznam_nemoci);

    printf("\n Podle ceho chcete nemoci radit? \n");
    printf(" -> 1 Podle jmena \n");
    printf(" -> 2 Podle poctu obeti \n");
    printf(" -> 3 Podle procentualiho umrti \n");

    printf("Vase volba: ");
    scanf("%d", &volba);
    system("cls");

    if(volba == 1)
    {
        for(int i = 0; i < pocet_nemoci; i++)
        {
            for(int j = 1; j < pocet_nemoci; j++)
            {
                if(strcmp(pole[j - 1].nazev_nemoci, pole[j].nazev_nemoci) > 0)
                {
                    pom = pole[j - 1];
                    pole[j - 1] = pole[j];
                    pole[j] = pom;
                }
            }
        }
    }

    else if(volba == 2)
    {
        for(int i = 0; i < pocet_nemoci; i++)
        {
            for(int j = 1; j < pocet_nemoci; j++)
            {
                if(pole[j - 1].pocet_umrti > pole[j].pocet_umrti)
                {
                    pom = pole[j - 1];
                    pole[j - 1] = pole[j];
                    pole[j] = pom;
                }
            }
        }
    }

    else if(volba == 3)
    {
        for(int i = 0; i < pocet_nemoci; i++)
        {
            for(int j = 1; j < pocet_nemoci; j++)
            {
                if(pole[j - 1].procento_mrtvych > pole[j].procento_mrtvych)
                {
                    pom = pole[j - 1];
                    pole[j - 1] = pole[j];
                    pole[j] = pom;
                }
            }
        }
    }

    NactenidoPole_Vypis(seznam_nemoci, pole, 1);
}

void UrceniPriznaku(FILE* help_file)
{
    char volba[4];
    char spravne[] = "ano";

    printf("\n -> Je priznakem teto nemoci nechutenstvi nebo hubnuti [ano/ne]: ");
    scanf("%3s", &volba);

    if(strcmp(volba, spravne) == 0) fprintf(help_file, ",nechutenstvi,hubnuti");

    printf("\n -> Je priznakem teto nemoci prujem [ano/ne]: ");
    scanf("%3s", &volba);

    if(strcmp(volba, spravne) == 0) fprintf(help_file, ",prujem");

    printf("\n -> Je priznakem teto nemoci zvraceni [ano/ne]: ");
    scanf("%3s", &volba);

    if(strcmp(volba, spravne) == 0) fprintf(help_file, ",zvraceni");

    printf("\n -> Je priznakem teto nemoci dusnost nebo obtizne dychani [ano/ne]: ");
    scanf("%3s", &volba);

    if(strcmp(volba, spravne) == 0) fprintf(help_file, ",dusnost,obtizne_dychani");

    printf("\n -> Je priznakem teto nemoci kychani nebo sipani [ano/ne]: ");
    scanf("%3s", &volba);

    if(strcmp(volba, spravne) == 0) fprintf(help_file, ",kychani,sipani");

    printf("\n -> Je priznakem teto nemoci onemocneni kuze [ano/ne]: ");
    scanf("%3s", &volba);

    if(strcmp(volba, spravne) == 0) fprintf(help_file, ",onemocneni_kuze");

    printf("\n -> Je priznakem teto nemoci onemocneni oci [ano/ne]: ");
    scanf("%3s", &volba);

    if(strcmp(volba, spravne) == 0) fprintf(help_file, ",onemocneni_oci");

    printf("\n -> Je priznakem teto nemoci nemoc nervove soustavy nebo krece [ano/ne]: ");
    scanf("%3s", &volba);

    if(strcmp(volba, spravne) == 0) fprintf(help_file, ",onemocneni_nervove_soustavy,krece");

    fprintf(help_file, ".");
}

void UpravaNemoci(FILE* seznam_nemoci, FILE* priznaky_nemoci, FILE* popis_nemoci, FILE* help_file, int pozice_nove_nemoci)
{
    system("cls");

    int i = 0;
    int pocet_nemoci = 0;
    int konec_priznaku = 0;
    int delka_posledniho_retezce = 0;
    char volba[4];
    char spravne[] = "ano";
    nemoc pole[100];
    nemoc_priznaky pole_priznaky[1000];
    nemoc_popis pole_popis[1000];

    pocet_nemoci = PocetNemoci(seznam_nemoci);
    NactenidoPole_Vypis(seznam_nemoci, pole, 2);

    printf("\n -> Zadej novy nazev nemoci [viceslovne nazvy oddeluj podtrzitkem]: ");
    scanf("%49s", &pole[pozice_nove_nemoci - 1].nazev_nemoci);

    printf("\n -> Zadej pocet obeti teto nemoci: ");
    scanf("%d", &pole[pozice_nove_nemoci - 1].pocet_umrti);

    printf("\n -> Zadej procentualni umrtnost nove nemoci: ");
    scanf("%f", &pole[pozice_nove_nemoci - 1].procento_mrtvych);

    rewind(seznam_nemoci);
    for(i = 0; i < pocet_nemoci; i++) fprintf(seznam_nemoci, "%d %s %d %0.2f \n", pole[i].id_nemoci, pole[i].nazev_nemoci, pole[i].pocet_umrti, pole[i].procento_mrtvych);
    rewind(priznaky_nemoci);
    for(i = 0; i < pocet_nemoci; i++) fscanf(priznaky_nemoci, "%d %999s", &pole_priznaky[i].id_nemoci, &pole_priznaky[i].priznaky_nemoci);
    rewind(help_file);

    system("cls");
    UrceniPriznaku(help_file);
    fseek(help_file, 1, SEEK_SET);
    fscanf(help_file, "%999s", &pole_priznaky[pozice_nove_nemoci - 1].priznaky_nemoci);

    rewind(priznaky_nemoci);
    for(i = 0; i < pocet_nemoci; i++) fprintf(priznaky_nemoci, "%d %s \n", pole_priznaky[i].id_nemoci, pole_priznaky[i].priznaky_nemoci);
    delka_posledniho_retezce = sizeof(pole_priznaky[pocet_nemoci - 1].priznaky_nemoci);
    for(i = 0; i < delka_posledniho_retezce; i++) fprintf(priznaky_nemoci, " ");
    system("cls");

    rewind(popis_nemoci);
    for(i = 0; i < pocet_nemoci; i++) fscanf(popis_nemoci, "%d %999s", &pole_popis[i].id_nemoci, &pole_popis[i].popis_nemoci);

    printf("\n -> Zadejte popis %s [jednotliva slova oddeluj podtrzitkem a na konci nezapomen na tecku]: ", pole[pozice_nove_nemoci - 1].nazev_nemoci);
    scanf("%999s", &pole_popis[pozice_nove_nemoci - 1].popis_nemoci);

    rewind(popis_nemoci);
    for(i = 0; i < pocet_nemoci; i++) fprintf(popis_nemoci, "%d %s \n", pole_popis[i].id_nemoci, pole_popis[i].popis_nemoci);
    delka_posledniho_retezce = sizeof(pole_popis[pocet_nemoci - 1].popis_nemoci);
    for(i = 0; i < delka_posledniho_retezce; i++) fprintf(popis_nemoci, " ");
    system("cls");
    printf("%s \n", pole_popis[pocet_nemoci].popis_nemoci);

    printf("-> zaznam o nemoci %s byl uspesne zmenen! \n", pole[pozice_nove_nemoci - 1].nazev_nemoci);
}

void PridaniNemoci(FILE* seznam_nemoci, FILE* priznaky_nemoci, FILE* popis_nemoci, FILE* help_file, int pozice_nove_nemoci)
{
    system("cls");

    int i = 0;
    int pocet_nemoci = 0;
    int konec_priznaku = 0;
    int delka_posledniho_retezce = 0;
    nemoc nova_nemoc;
    nemoc pole[100];
    nemoc_priznaky pole_priznaky[1000];
    nemoc_priznaky novy_priznak;
    nemoc_popis pole_popis[1000];
    nemoc_popis novy_popis;

    pocet_nemoci = PocetNemoci(seznam_nemoci);
    NactenidoPole_Vypis(seznam_nemoci, pole, 2);

    printf("\n -> Zadej nazev nove nemoci [viceslovne nazvy oddeluj podtrzitkem]: ");
    scanf("%49s", &nova_nemoc.nazev_nemoci);

    printf("\n -> Zadej pocet obeti teto nemoci: ");
    scanf("%d", &nova_nemoc.pocet_umrti);

    printf("\n -> Zadej procentualni umrtnost nove nemoci: ");
    scanf("%f", &nova_nemoc.procento_mrtvych);

    rewind(seznam_nemoci);
    while(1)
    {
        if(i == (pozice_nove_nemoci - 1))
        {
            fprintf(seznam_nemoci, "%d %s %d %0.2f \n", pole[i].id_nemoci, nova_nemoc.nazev_nemoci, nova_nemoc.pocet_umrti, nova_nemoc.procento_mrtvych);
            fprintf(seznam_nemoci, "%d %s %d %0.2f \n", (pole[i].id_nemoci + 1), pole[i].nazev_nemoci, pole[i].pocet_umrti, pole[i].procento_mrtvych);
            break;
        }
        else fprintf(seznam_nemoci, "%d %s %d %0.2f \n", pole[i].id_nemoci, pole[i].nazev_nemoci, pole[i].pocet_umrti, pole[i].procento_mrtvych);

        i++;
    }

    i++;

    while(i < pocet_nemoci)
    {
        pole[i].id_nemoci += 1;
        fprintf(seznam_nemoci, "%d %s %d %0.2f \n", pole[i].id_nemoci, pole[i].nazev_nemoci, pole[i].pocet_umrti, pole[i].procento_mrtvych);

        i++;
    }

    delka_posledniho_retezce = sizeof(pole[pocet_nemoci - 1].nazev_nemoci);
    for(i = 0; i < delka_posledniho_retezce; i++) fprintf(seznam_nemoci, " ");
    system("cls");

    rewind(priznaky_nemoci);
    for(i = 0; i < pocet_nemoci; i++) fscanf(priznaky_nemoci, "%d %999s", &pole_priznaky[i].id_nemoci, &pole_priznaky[i].priznaky_nemoci);
    rewind(help_file);

    system("cls");
    UrceniPriznaku(help_file);
    fseek(help_file, 1, SEEK_SET);
    fscanf(help_file, "%999s", &novy_priznak.priznaky_nemoci);

    rewind(priznaky_nemoci);
    i = 0;
    while(1)
    {
        if(i == (pozice_nove_nemoci - 1))
        {
            fprintf(priznaky_nemoci, "%d %s \n", pole_priznaky[i].id_nemoci, novy_priznak.priznaky_nemoci);
            fprintf(priznaky_nemoci, "%d %s \n", (pole_priznaky[i].id_nemoci + 1), pole_priznaky[i].priznaky_nemoci);
            break;
        }
        else fprintf(priznaky_nemoci, "%d %s \n", pole_priznaky[i].id_nemoci, pole_priznaky[i].priznaky_nemoci);

        i++;
    }

    i++;

    while(i < pocet_nemoci)
    {
        pole_priznaky[i].id_nemoci += 1;
        fprintf(priznaky_nemoci, "%d %s \n", pole_priznaky[i].id_nemoci, pole_priznaky[i].priznaky_nemoci);

        i++;
    }

    delka_posledniho_retezce = sizeof(pole_priznaky[pocet_nemoci - 1].priznaky_nemoci);
    for(i = 0; i < delka_posledniho_retezce; i++) fprintf(priznaky_nemoci, " ");
    system("cls");

    rewind(popis_nemoci);
    for(i = 0; i < pocet_nemoci; i++) fscanf(popis_nemoci, "%d %999s", &pole_popis[i].id_nemoci, &pole_popis[i].popis_nemoci);

    printf("\n -> Zadejte popis %s [jednotliva slova oddeluj podtrzitkem a na konci nezapomen na tecku]: ", pole[pozice_nove_nemoci - 1].nazev_nemoci);
    scanf("%999s", &novy_popis.popis_nemoci);

    rewind(popis_nemoci);
    i = 0;
    while(1)
    {
        if(i == (pozice_nove_nemoci - 1))
        {
            fprintf(popis_nemoci, "%d %s \n", pole_popis[i].id_nemoci, novy_popis.popis_nemoci);
            fprintf(popis_nemoci, "%d %s \n", (pole_popis[i].id_nemoci + 1), pole_popis[i].popis_nemoci);
            break;
        }
        else fprintf(popis_nemoci, "%d %s \n", pole_popis[i].id_nemoci, pole_popis[i].popis_nemoci);

        i++;
    }

    i++;

    while(i < pocet_nemoci)
    {
        pole_popis[i].id_nemoci += 1;
        fprintf(popis_nemoci, "%d %s \n", pole_popis[i].id_nemoci, pole_popis[i].popis_nemoci);

        i++;
    }

    delka_posledniho_retezce = sizeof(pole_popis[pocet_nemoci - 1].popis_nemoci);
    for(i = 0; i < delka_posledniho_retezce; i++) fprintf(popis_nemoci, " ");
    system("cls");
    printf("-> nemoc %s byla uspesne pridana do databaze!, pod cislem %d \n", nova_nemoc.nazev_nemoci, pozice_nove_nemoci);
}

void SmazaniNemoci(FILE* seznam_nemoci, FILE* priznaky_nemoci, FILE* popis_nemoci, FILE* help_file, int pozice_nove_nemoci)
{
    system("cls");

    int i = 0;
    int pocet_nemoci = 0;
    int konec_priznaku = 0;
    int delka_posledniho_retezce = 0;
    nemoc pole[100];
    nemoc_priznaky pole_priznaky[1000];
    nemoc_popis pole_popis[1000];

    pocet_nemoci = PocetNemoci(seznam_nemoci);
    NactenidoPole_Vypis(seznam_nemoci, pole, 2);

    rewind(seznam_nemoci);
    while(1)
    {
        if(i == (pozice_nove_nemoci - 1)) break;
        else fprintf(seznam_nemoci, "%d %s %d %0.2f \n", pole[i].id_nemoci, pole[i].nazev_nemoci, pole[i].pocet_umrti, pole[i].procento_mrtvych);

        i++;
    }

    i++;

    while(i < pocet_nemoci)
    {
        pole[i].id_nemoci -= 1;
        fprintf(seznam_nemoci, "%d %s %d %0.2f \n", pole[i].id_nemoci, pole[i].nazev_nemoci, pole[i].pocet_umrti, pole[i].procento_mrtvych);

        i++;
    }
    
    delka_posledniho_retezce = sizeof(pole[pocet_nemoci - 1].nazev_nemoci);
    for(i = 0; i < delka_posledniho_retezce; i++) fprintf(seznam_nemoci, " ");
    system("cls");

    for(i = 0; i < pocet_nemoci; i++) fscanf(priznaky_nemoci, "%d %999s", &pole_priznaky[i].id_nemoci, &pole_priznaky[i].priznaky_nemoci);

    rewind(priznaky_nemoci);
    i = 0;
    while(1)
    {
        if(i == (pozice_nove_nemoci - 1)) break;
        else fprintf(priznaky_nemoci, "%d %s \n", pole_priznaky[i].id_nemoci, pole_priznaky[i].priznaky_nemoci);

        i++;
    }

    i++;

    while(i < pocet_nemoci)
    {
        pole_priznaky[i].id_nemoci -= 1;
        fprintf(priznaky_nemoci, "%d %s \n", pole_priznaky[i].id_nemoci, pole_priznaky[i].priznaky_nemoci);

        i++;
    }

    delka_posledniho_retezce = sizeof(pole_priznaky[pocet_nemoci - 1].priznaky_nemoci);
    for(i = 0; i < delka_posledniho_retezce; i++) fprintf(priznaky_nemoci, " ");
    system("cls");

    rewind(popis_nemoci);
    for(i = 0; i < pocet_nemoci; i++) fscanf(popis_nemoci, "%d %999s", &pole_popis[i].id_nemoci, &pole_popis[i].popis_nemoci);

    rewind(popis_nemoci);
    i = 0;
    while(1)
    {
        if(i == (pozice_nove_nemoci - 1)) break;
        else fprintf(popis_nemoci, "%d %s \n", pole_popis[i].id_nemoci, pole_popis[i].popis_nemoci);

        i++;
    }

    i++;

    while(i < pocet_nemoci)
    {
        pole_popis[i].id_nemoci -= 1;
        fprintf(popis_nemoci, "%d %s \n", pole_popis[i].id_nemoci, pole_popis[i].popis_nemoci);

        i++;
    }

    delka_posledniho_retezce = sizeof(pole_popis[pocet_nemoci - 1].popis_nemoci);
    for(i = 0; i < delka_posledniho_retezce; i++) fprintf(popis_nemoci, " ");
    system("cls");
    
    printf("-> nemoc %s byla uspesne smazana z databaze! \n", pole[pozice_nove_nemoci - 1].nazev_nemoci, pozice_nove_nemoci);
}

int main(void)
{
    FILE *seznam_nemoci;
    FILE *priznaky_nemoci;
    FILE *popis_nemoci;
    FILE* help_file;

    int pocet_nemoci = 0;
    int konec = 1;
    int volba;
    int id;
    int pozice = 0;

    seznam_nemoci = fopen("seznam_nemoci.txt", "r+");
    if (seznam_nemoci == NULL)
    {
        printf("Soubor se seznamem nemoci nebyl otevren \n");
        return 1;
    }

    priznaky_nemoci = fopen("priznaky_nemoci.txt", "r+");
    if (priznaky_nemoci == NULL)
    {
        printf("Soubor s priznaky nemoci nebyl otevren \n");
        return 1;
    }

    popis_nemoci = fopen("popis_nemoci.txt", "r+");
    if (popis_nemoci == NULL)
    {
        printf("Soubor s popisem nemoci nebyl otevren \n");
        return 1;
    }

    help_file = fopen("help_file.txt", "w+");
    if (help_file == NULL) 
    {
        printf("Pomocny soubor nebyl otevren \n");
        return 1;
    }

    while(konec)
    {
        pocet_nemoci = PocetNemoci(seznam_nemoci);
        rewind(seznam_nemoci);
        printf("Pocet nemoci je %d \n \n", pocet_nemoci);
        volba = menu();

        switch(volba)
        {
            case 1: system("cls");

                    VypisNemoci(seznam_nemoci);
                    rewind(seznam_nemoci);

                    system("pause");
                    system("cls");
                    break;

            case 2: system("cls");

                    rewind(seznam_nemoci);
                    VypisNemoci(seznam_nemoci);
                    rewind(seznam_nemoci);
                    rewind(priznaky_nemoci);

                    printf("\n Zadej cislo nemoci, jejiz priznaky chces vypsat: ");
                    scanf("%d", &id);
                    system("cls");
                    NazevNemoci(seznam_nemoci, id);
                    OhranicenyVypis();
                    VypisPriznaku(priznaky_nemoci, seznam_nemoci, id);
                    rewind(seznam_nemoci);
                    rewind(priznaky_nemoci);

                    system("pause");
                    system("cls");
                    break;

            case 3: system("cls");

                    rewind(seznam_nemoci);
                    VypisNemoci(seznam_nemoci);
                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);

                    printf("\n Zadej cislo nemoci, o ktere se chcete dozvedet vice: ");
                    scanf("%d", &id);
                    system("cls");
                    NazevNemoci(seznam_nemoci, id);
                    OhranicenyVypis();
                    VypisPopisu(popis_nemoci, seznam_nemoci, id);
                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);

                    system("pause");
                    system("cls");
                    break;

            case 4: system("cls");

                    rewind(seznam_nemoci);
                    VypisNemoci(seznam_nemoci);
                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);

                    printf("\n Zadej cislo nemoci, o ktere se chcete dozvedet uplne vsechno: ");
                    scanf("%d", &id);
                    system("cls");
                    VypisVseho(seznam_nemoci, priznaky_nemoci, popis_nemoci, id);
                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);

                    system("pause");
                    system("cls");
                    break;

            case 5: system("cls");

                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);

                    HledaniNemoci(seznam_nemoci, priznaky_nemoci, popis_nemoci);
                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);

                    system("pause");
                    system("cls");
                    break;

            case 6: system("cls");

                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);

                    RazeniNemoci(seznam_nemoci, priznaky_nemoci, popis_nemoci);
                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);

                    system("pause");
                    system("cls");
                    break;

            case 7: system("cls");

                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);

                    VypisNemoci(seznam_nemoci);
                    printf("\n Vyber nemoc, jejiz zaznamy chces upravit: ");
                    scanf("%d", &pozice);
                    
                    UpravaNemoci(seznam_nemoci, priznaky_nemoci, popis_nemoci,help_file, pozice);
                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);
                    system("pause");
                    system("cls");
                    break;

            case 8: system("cls");

                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);

                    VypisNemoci(seznam_nemoci);
                    printf("\n Vyber pozici, kam chces pridat novou nemoc: ");
                    scanf("%d", &pozice);
                    
                    PridaniNemoci(seznam_nemoci, priznaky_nemoci, popis_nemoci,help_file, pozice);
                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);
                    system("pause");
                    system("cls");
                    break;

            case 9: system("cls");

                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);

                    VypisNemoci(seznam_nemoci);
                    printf("\n Vyber nemoc, kterou chcete smazat: ");
                    scanf("%d", &pozice);
                    
                    SmazaniNemoci(seznam_nemoci, priznaky_nemoci, popis_nemoci,help_file, pozice);
                    rewind(seznam_nemoci);
                    rewind(popis_nemoci);
                    rewind(priznaky_nemoci);
                    system("pause");
                    system("cls");
                    break;   

            default:
                konec=0;
        } //konec switch
    } // konec while

    printf("\n  DIKY ZA SPUSTENI :) ! \n");

    fclose(seznam_nemoci);
    fclose(popis_nemoci);
    fclose(priznaky_nemoci);
    fclose(help_file);

    return 0;
}
