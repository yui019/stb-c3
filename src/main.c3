module stb;
import image;
import image_write;
import std::io;
import raylib5::rl;

fn int main(String[] args)
{
    const int SCREEN_WIDTH = 800;
    const int SCREEN_HEIGHT = 450;

    rl::initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window");
    rl::setTargetFPS(60);
	
	int image_width = 0;
	int image_height = 0;
	int image_channels_count = 0;
	// File file = io::file::open("resources/test.png", "r")!!;
	// char *image_data = image::load_from_file(file.file, &image_width, &image_height, &image_channels_count, image::RGB_ALPHA);
	char *image_data = image::load("resources/test.png", &image_width, &image_height, &image_channels_count, image::RGB_ALPHA);

	image_write::flip_vertically_on_write(true);
	image_write::write_bmp("resources/out.bmp", image_width, image_height, 4, image_data);

	Image image = Image {
		.data = image_data,
		.width = image_width,
		.height = image_height,
		.mipmaps = 1,
		.format = PixelFormat.UNCOMPRESSED_R8G8B8A8,
	};

	Texture2D texture = rl::loadTextureFromImage(image);

    while (!rl::windowShouldClose())
    {
        rl::beginDrawing();

            rl::clearBackground(rl::RAYWHITE);

            rl::drawText("Congrats! You created your first window!", 190, 200, 20, rl::LIGHTGRAY);
			rl::drawTextureEx(texture, Vector2 { .x = 0, .y = 0 }, 0, 0.5, rl::WHITE);

        rl::endDrawing();
    }

    rl::closeWindow();
	return 0;
}
