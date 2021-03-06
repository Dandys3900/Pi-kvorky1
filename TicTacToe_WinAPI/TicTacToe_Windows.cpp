#include "framework.h"
#include "TicTacToe_WinAPI_Game.h"
#include <windowsx.h>

#define MAX_LOADSTRING 100

// Global variables:
HINSTANCE hInst;                                  // Actual instance
WCHAR szTitle[MAX_LOADSTRING];                    // Header text
WCHAR szWindowClass[MAX_LOADSTRING];              // Main window class name
const int CELL_SIZE = 100;
HBRUSH hbr1, hbr2;                                // Global brush variables
HICON hIcon1, hIcon2;                             // Global icons for Player1 and Player2
const int field_size = 5;                         // field_size 3 -> field 3x3
int PlayerTurn = 1;
int GameBoard[field_size * field_size];           // Field which contains each cell number (0-8)
int Winner = 0;
int wins[field_size];

ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK    About(HWND, UINT, WPARAM, LPARAM);

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
    _In_opt_ HINSTANCE hPrevInstance,
    _In_ LPWSTR    lpCmdLine,
    _In_ int       nCmdShow) {
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    // Initialization of global strings:
    LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
    LoadStringW(hInstance, IDC_TICTACTOEWINAPIGAME, szWindowClass, MAX_LOADSTRING);
    MyRegisterClass(hInstance);

    // Initialization of application:
    if (!InitInstance(hInstance, nCmdShow))
        return FALSE;

    HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_TICTACTOEWINAPIGAME));
    MSG msg;

    // Main message loop:
    while (GetMessage(&msg, nullptr, 0, 0))
    {
        if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }

    return (int)msg.wParam;
}

//////////////////////////////////////////////////
//  FUNCTION: MyRegisterClass(HINSTANCE)        //
//  PURPOSE: Registration of the window class.  //
//////////////////////////////////////////////////
ATOM MyRegisterClass(HINSTANCE hInstance)
{
    WNDCLASSEXW wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);

    wcex.style = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc = WndProc;
    wcex.cbClsExtra = 0;
    wcex.cbWndExtra = 0;
    wcex.hInstance = hInstance;
    wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_MAINICON));
    wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wcex.lpszMenuName = MAKEINTRESOURCEW(IDC_TICTACTOEWINAPIGAME);
    wcex.lpszClassName = szWindowClass;
    wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_MAINICON));

    return RegisterClassExW(&wcex);
}

////////////////////////////////////////////////////////////////////////////////////
//   FUNCTION: InitInstance(HINSTANCE, int)                                       //
//   PURPOSE: Saves the instance handle and creates the main window.              //
//   COMMENTS:                                                                    //
//          In this function, we store the instance handle in a global variable   //
//          and create and display the main program window.                       //
////////////////////////////////////////////////////////////////////////////////////
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
    hInst = hInstance;

    HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);

    if (!hWnd)
        return FALSE;

    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);

    return TRUE;
}

/////////////////////////////////////////////////////////////
//  FUNCTION: GetGameBoardRect(HWND, RECT)                 //
//  PURPOSE: Processes messages for the main window.       //
//                                                         //
//  WM_COMMAND  - handle application requests              //
//  WM_PAINT    - render of the main window                //
//  WM_DESTROY  - issuing a termination and return report  //
/////////////////////////////////////////////////////////////
BOOL GetGameBoardRect(HWND hwnd, RECT* pRect)
{
    RECT rc;
    if (GetClientRect(hwnd, &rc)) // Function for getting window size
    {
        int width = rc.right - rc.left;
        int height = rc.bottom - rc.top;

        pRect->left = ((width - (CELL_SIZE * field_size)) / 2);
        pRect->top = ((height - (CELL_SIZE * field_size)) / 2);

        pRect->right = (pRect->left + (CELL_SIZE * field_size));
        pRect->bottom = (pRect->top + (CELL_SIZE * field_size));

        return TRUE;
    }

    SetRectEmpty(pRect);
    return FALSE;
}

//////////////////////////////////////////////////
//  FUNCTION: DrawLine(HDC, int, int, int, int) //
//  PURPOSE: Draw a line from [x1,y1] point     //
//           to [x2,y2] point.                  //
//////////////////////////////////////////////////
void DrawLine(HDC hdc, int x1, int y1, int x2, int y2)
{
    MoveToEx(hdc, x1, y1, NULL); // Draw a line across the rectangle
    LineTo(hdc, x2, y2);
}

////////////////////////////////////////////////////////
//  FUNCTION: GetCellNumberFromPoint(HWND, int, int)  //
//  PURPOSE: Get cell number (0-8) from position      //
//           of user´s click.                         //
////////////////////////////////////////////////////////
int GetCellNumberFromPoint(HWND hwnd, int x, int y)
{
    POINT pt;
    RECT rc;

    pt.x = x;
    pt.y = y;

    if (GetGameBoardRect(hwnd, &rc))
    {
        if (PtInRect(&rc, pt))
        {
            // User clicked inside game field
            x = pt.x - rc.left; // How far is the click from the table left edge (distance of x from window beggining - distance of left square from window beggining), field size is 300
            y = pt.y - rc.top;

            int column = (x / CELL_SIZE);
            int row = (y / CELL_SIZE);

            // Convert to index
            return (column + (row * field_size));
        }
    }

    return -1;
}

////////////////////////////////////////////////////////
//  FUNCTION: GetCellRect(HWND, int, RECT*)           //
//  PURPOSE: Convert index of cell to [x,y] position. //
////////////////////////////////////////////////////////
BOOL GetCellRect(HWND hwnd, int index, RECT* pRect)
{
    RECT rcBoard;

    SetRectEmpty(pRect); // Set rectangle to zeros
    if (index < 0 || index > (field_size * field_size))
        return FALSE;

    else if (GetGameBoardRect(hwnd, &rcBoard))
    {
        int x = (index % field_size); // Column (sloupec) number
        int y = (index / field_size); // Row (radek) number

        pRect->left = (rcBoard.left + (x * CELL_SIZE) + 1);
        pRect->top = (rcBoard.top + (y * CELL_SIZE) + 1);

        pRect->right = (pRect->left + CELL_SIZE - 1);
        pRect->bottom = (pRect->top + CELL_SIZE - 1);

        return TRUE;
    }

    return FALSE;
}

//////////////////////////////////////////////
//  FUNCTION: GetWinner(int)                //
//  PURPOSE: Detect a winner in cell field. //
//////////////////////////////////////////////
int GetWinner(int num_of_lines)
{
    int number = 0;
    int a = 1;
    int* cells = (int*)malloc(sizeof(int));

    if (cells)
    {
        for (int i = 0; i < (num_of_lines * (num_of_lines + num_of_lines + 2)); i++)
        {
            if (i >= 0 && i < (num_of_lines * num_of_lines))
                cells[i] = i;
            else if (i >= (num_of_lines * num_of_lines) && i < ((num_of_lines * num_of_lines) * 2))
            {
                if (i == ((num_of_lines * num_of_lines) + (num_of_lines * a)))
                {
                    number = a;
                    a++;
                }

                cells[i] = number;
                number += num_of_lines;
            }
            else if (i >= ((num_of_lines * num_of_lines) * 2) && i < (((num_of_lines * num_of_lines) * 2) + num_of_lines))
            {
                if (i == ((num_of_lines * num_of_lines) * 2))
                    number = 0;
                cells[i] = number;
                number += (num_of_lines + 1);
            }
            else if (i >= (((num_of_lines * num_of_lines) * 2) + num_of_lines))
            {
                if (i == (((num_of_lines * num_of_lines) * 2) + num_of_lines))
                    number = (num_of_lines - 1);
                cells[i] = number;
                number += (num_of_lines - 1);
            }
        }

        int still_true = -1;

        for (int i = 0; i < (num_of_lines * (num_of_lines + num_of_lines + 2)); i += num_of_lines)
        {
            if (GameBoard[cells[i]] != 0)
            {
                for (int x = 1; x < num_of_lines; x++)
                {
                    if (GameBoard[cells[i]] == GameBoard[cells[i + x]])
                        still_true = 1;
                    else
                    {
                        still_true = 0;
                        x = num_of_lines;
                    }
                }
            }

            if (still_true == 1)
            {
                for (int y = 0; y < num_of_lines; y++)
                    wins[y] = cells[i + y];

                return GameBoard[cells[i]];
            }
        }

        if (still_true != 1)
        {
            for (int i = 0; i < (num_of_lines * num_of_lines); i++)
            {
                if (GameBoard[i] != 1 || GameBoard[i] != 2)
                    return 0; // Empty cells => continue in game
            }
        }
    }

    free(cells);
    return 3;
}

//////////////////////////////////////////////////
//  FUNCTION: ShowTurn(HWND, HDC)               //
//  PURPOSE: Shows players turns in window.     //
//////////////////////////////////////////////////
void ShowTurn(HWND hWnd, HDC hdc)
{
    RECT rc;
    const WCHAR str_Turn1[] = L"Turn: Player 1";
    const WCHAR str_Turn2[] = L"Turn: Player 2";

    const WCHAR* TurnText = NULL;

    switch (Winner)
    {
    case 0: // Continue the game
        TurnText = ((PlayerTurn == 1) ? str_Turn1 : str_Turn2);
        break;

    case 1: // Player1 wins
        TurnText = L"Player 1 is the winner!";
        break;

    case 2: // Player2 wins
        TurnText = L"Player 2 is the winner!";
        break;

    case 3: // It is a draw
        TurnText = L"It is a draw!";
        break;

    default:
        break;
    }

    if (TurnText && GetClientRect(hWnd, &rc))
    {
        rc.top = (rc.bottom - 48); // Draw 48 pixel above bottom corner of window
        FillRect(hdc, &rc, (HBRUSH)(COLOR_WINDOW + 1));

        if (PlayerTurn == 1 || Winner == 1)
            SetTextColor(hdc, RGB(255, 0, 0));
        else if (PlayerTurn == 2 || Winner == 2)
            SetTextColor(hdc, RGB(0, 0, 255));

        SetBkMode(hdc, TRANSPARENT);
        DrawText(hdc, TurnText, lstrlen(TurnText), &rc, DT_CENTER);
    }
}

///////////////////////////////////////////////////////
//  FUNCTION: DrawIconCentered(HDC, RECT*, HICON)    //
//  PURPOSE: Draws icons centered in cells.          //
///////////////////////////////////////////////////////
void DrawIconCentered(HDC hdc, RECT* pRect, HICON hIcon)
{
    const int ICON_WIDTH = GetSystemMetrics(SM_CXICON);
    const int ICON_HEIGHT = GetSystemMetrics(SM_CXICON);

    if (pRect)
    {
        int left = (pRect->left + ((pRect->right - pRect->left) - ICON_WIDTH) / 2);
        int top = (pRect->top + ((pRect->bottom - pRect->top) - ICON_HEIGHT) / 2);

        DrawIcon(hdc, left, top, hIcon);
    }
}

///////////////////////////////////////////
//  FUNCTION: ShowWinner(HWND, HDC)      //
//  PURPOSE: Highlight the winner.       //
///////////////////////////////////////////
void ShowWinner(HWND hwnd, HDC hdc)
{
    RECT rcWin;

    for (int i = 0; i < field_size; i++)
    {
        if (GetCellRect(hwnd, wins[i], &rcWin))
        {
            FillRect(hdc, &rcWin, ((Winner == 1) ? hbr1 : hbr2));
            DrawIconCentered(hdc, &rcWin, ((Winner == 1) ? hIcon1 : hIcon2));
        }
    }
}

/////////////////////////////////////////////////////////////
//  FUNCTION:WndProc(HWND, UNIT, WPARAM, LPARAM)           //
//  PURPOSE: Handle messages from window.                  //
//                                                         //
//  WM_COMMAND  - handle application requests              //
//  WM_PAINT    - render of the main window                //
//  WM_DESTROY  - issuing a termination and return report  //
/////////////////////////////////////////////////////////////
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
        case WM_CREATE:
        {
            // Creating of the new brush
            hbr1 = CreateSolidBrush(RGB(255, 0, 0)); // Red
            hbr2 = CreateSolidBrush(RGB(0, 0, 255)); // Blue

            // Load players icons
            hIcon1 = LoadIcon(hInst, MAKEINTRESOURCE(IDI_ICON_PLAYER1));
            hIcon2 = LoadIcon(hInst, MAKEINTRESOURCE(IDI_ICON_PLAYER2));
        }
        break;

        case WM_COMMAND:
        {
            int wmId = LOWORD(wParam);

            switch (wmId)
            {
                case ID_FILE_NEWGAME:
                {
                    int return_value = MessageBox(hWnd, L"Are you sure you want to start a new game?", L"New Game", MB_YESNO | MB_ICONQUESTION);
                    if (return_value == IDYES)
                    {
                        PlayerTurn = 1;
                        Winner = 0;
                        ZeroMemory(GameBoard, sizeof(GameBoard)); // Set GameBoard values to 0
                        InvalidateRect(hWnd, NULL, TRUE); // Reset paint of the whole window
                        UpdateWindow(hWnd);
                    }
                }
                break;

                case ID_FILE_SETTINGS:
                {
                    HDC hdc = GetDC(hWnd);

                    if (message == ID_SETTINGS_SETFIELDSIZE)
                        MessageBox(hWnd, L"Are you sure you want to start a new game?", L"New Game", MB_YESNO | MB_ICONQUESTION);
                }
                break;

                case IDM_ABOUT:
                    DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
                    break;
                case IDM_EXIT:
                {
                    int return_value = MessageBox(hWnd, L"Are you sure you want to exit?", L"Exit", MB_YESNO | MB_ICONQUESTION);
                    if (return_value == IDYES)
                        DestroyWindow(hWnd);
                }
                break;

                default:
                    return DefWindowProc(hWnd, message, wParam, lParam);
            }
        }
        break;

        case WM_LBUTTONDOWN:
        {
            int xPos = GET_X_LPARAM(lParam);
            int yPos = GET_Y_LPARAM(lParam);

            int index = GetCellNumberFromPoint(hWnd, xPos, yPos); // Number of cell, where user clicked

            HDC hdc = GetDC(hWnd);
            if (hdc)
            {
                // Get cell dimension from its index
                if (index >= 0 && index < (field_size * field_size))
                {
                    RECT rcCell;
                    if ((GameBoard[index] != 1) && (GameBoard[index] != 2) && (GetCellRect(hWnd, index, &rcCell)))
                    {
                        GameBoard[index] = PlayerTurn;
                        DrawIconCentered(hdc, &rcCell, ((PlayerTurn == 1) ? hIcon1 : hIcon2));

                        // Check for a winner
                        Winner = GetWinner(field_size);
                        if (Winner == 1 || Winner == 2)
                        {
                            ShowWinner(hWnd, hdc);
                            MessageBox(hWnd,
                                (Winner == 1) ? L"Player 1 is the winner!" : L"Player 2 is the winner!",
                                L"You win!",
                                MB_OK | MB_ICONINFORMATION); //  MB is type of buttons which will appears in window
                            PlayerTurn = 0;
                        }
                        else if (Winner == 3)
                        {
                            MessageBox(hWnd,
                                L"Oh! It is a draw!",
                                L"No winners!", MB_OK | MB_ICONEXCLAMATION);
                            PlayerTurn = 0;
                        }
                        else
                            PlayerTurn = ((PlayerTurn == 1) ? 2 : 1);

                        // Display turn
                        ShowTurn(hWnd, hdc);
                    }
                }
            }

        }
        break;

        case WM_GETMINMAXINFO:
        {
            MINMAXINFO* pMinMax = (MINMAXINFO*)lParam;

            if (pMinMax)
            {
                pMinMax->ptMinTrackSize.x = CELL_SIZE * (field_size + 2); // Make sure that window wont be smaller than painted rectangle
                pMinMax->ptMinTrackSize.y = CELL_SIZE * (field_size + 2);
            }
        }
        break;

        case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hWnd, &ps);
            RECT rc;

            if (GetGameBoardRect(hWnd, &rc))
            {
                RECT rcClient;

                if (GetClientRect(hWnd, &rcClient))
                {
                    const WCHAR str_Player1[] = L"Player 1";
                    const WCHAR str_Player2[] = L"Player 2";

                    SetBkMode(hdc, TRANSPARENT); // To have always same background color of text and window

                    SetTextColor(hdc, RGB(255, 0, 0));
                    TextOut(hdc, 25, 25, str_Player1, lstrlen(str_Player1));
                    DrawIcon(hdc, 34, 50, hIcon1); // Draw Player1 icon below text
                    SetTextColor(hdc, RGB(0, 0, 255));
                    TextOut(hdc, (rcClient.right - 81), 25, str_Player2, lstrlen(str_Player2));
                    DrawIcon(hdc, (rcClient.right - 72), 50, hIcon2);

                    // Display turn
                    ShowTurn(hWnd, hdc);
                }

                FillRect(hdc, &rc, (HBRUSH)GetStockObject(WHITE_BRUSH));
            }

            for (int i = 0; i < (field_size + 1); i++)
            {
                // Draw vertical lines
                DrawLine(hdc, rc.left + (CELL_SIZE * i), rc.top, rc.left + (CELL_SIZE * i), rc.bottom);
                // Draw horizontal lines
                DrawLine(hdc, rc.left, rc.top + (CELL_SIZE * i), rc.right, rc.top + (CELL_SIZE * i));
            }

            // Draw all occupied cells
            RECT rcCell;
            for (int i = 0; i < (field_size * field_size); i++)
            {
                if (((GameBoard[i] == 1) || (GameBoard[i] == 2)) && (GetCellRect(hWnd, i, &rcCell)))
                    DrawIconCentered(hdc, &rcCell, ((GameBoard[i] == 1) ? hIcon1 : hIcon2));
            }

            // Show winner
            if (Winner == 1 || Winner == 2)
                ShowWinner(hWnd, hdc);

            EndPaint(hWnd, &ps);
        }
        break;

        case WM_DESTROY:
            DeleteObject(hbr1);
            DeleteObject(hbr2);
            DestroyIcon(hIcon1);
            DestroyIcon(hIcon2);
            PostQuitMessage(0);
        break;

        default:
            return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}

/////////////////////////////////////////////////////
//  FUNCTION:About(HWND, UNIT, WPARAM, LPARAM)     //
//  PURPOSE: Handle dialog messages.               //
/////////////////////////////////////////////////////
INT_PTR CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    UNREFERENCED_PARAMETER(lParam);
    switch (message)
    {
    case WM_INITDIALOG:
        return (INT_PTR)TRUE;

    case WM_COMMAND:
        if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
        {
            EndDialog(hDlg, LOWORD(wParam));
            return (INT_PTR)TRUE;
        }
        break;
    }
    return (INT_PTR)FALSE;
}
