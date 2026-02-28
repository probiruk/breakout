#include "raylib.h"

int main(void)
{
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib example");

    Vector2 position = { 100.0f, 200.0f };
    float speed = 200.0f;

    SetTargetFPS(60);

    while (!WindowShouldClose())
    {
        float delta = GetFrameTime();

        // Move rectangle with arrow keys
        if (IsKeyDown(KEY_RIGHT)) position.x += speed * delta;
        if (IsKeyDown(KEY_LEFT))  position.x -= speed * delta;
        if (IsKeyDown(KEY_UP))    position.y -= speed * delta;
        if (IsKeyDown(KEY_DOWN))  position.y += speed * delta;

        BeginDrawing();
            ClearBackground(RAYWHITE);

            DrawText("Move the square with arrow keys", 10, 10, 20, DARKGRAY);
            DrawRectangleV(position, (Vector2){ 50, 50 }, BLUE);

        EndDrawing();
    }

    CloseWindow();
    return 0;
}
