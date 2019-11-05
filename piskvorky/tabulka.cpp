#include "Vykreslitabulku.h"

using namespace std;

class tabulka
{
	int vykresli(int delka_tabulky, int sirka_tabulky, int pocetradku, int pocetsloupcu)
	{
		if (SDL_Init(SDL_INIT_EVERYTHING))
		{
			cout << "SDL_Init Error: " << SDL_GetError() << endl;
			return 1;
		}

		SDL_Window* win = SDL_CreateWindow("Obrazovka", 5, 5, delka_tabulky, sirka_tabulky, SDL_WINDOW_SHOWN);

		if (!win)
		{
			cout << "SDL_CreateWindow Error: " << SDL_GetError() << endl;
			return 2;
		}

		SDL_Renderer* ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

		if (!ren)
		{
			cout << "SDL_CreateRenderer Error: " << SDL_GetError() << endl;
			return 3;
		}

		SDL_Event event;
		bool done = false;

		while (!done)
		{
			for (int i = 0; i < pocetradku; i++)
			{
				SDL_SetRenderDrawColor(ren, 100, 100, 0, 0);
				SDL_RenderDrawLine(ren, 100, 100, 20, 20);
			}			

			SDL_RenderPresent(ren);

			while (SDL_PollEvent(&event))
			{
				if (event.type == SDL_QUIT)
					done = true;
			}
		}

		SDL_DestroyRenderer(ren);
		SDL_DestroyWindow(win);
		SDL_Quit();

		return 0;
	}
};
