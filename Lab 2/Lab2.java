
import java.util.Arrays;
import java.util.Scanner;

public class Lab2 {
	// This named constant will be declared with .eqv
	static final int INPUT_SIZE = 3;

	// These variables will go in the .data segment.
	static int display = 0;
	static char[] input = new char[INPUT_SIZE];

	public static void main(String[] args) {
		// Use the print_str macro to easily print messages.
		System.out.print("Welcome to CALCY THE CALCULATOR!\n");

		while(true) {
			System.out.print(display); // syscall #1
			System.out.print("\nOperation (=,+,-,*,/,c,q): ");
			read_string(input, INPUT_SIZE); // syscall #8

			switch(input[0]) {
				case 'q':
					System.exit(0); // syscall #10

				case 'c':
					display = 0;
					break;

				case '+': case '-': case '*': case '/': case '=':
					System.out.print("Value: ");
					int value = read_int(); // syscall #5, and 'value' is gonna be in v0.

					switch(input[0]) {
						case '+':
							display += value;
							break;
						case '-':
							display -= value;
							break;
						case '*':
							display *= value;
							break;
						case '/':
							if(value == 0)
								System.out.print("Attempting to divide by 0!\n");
							else
								display /= value;
							break;

						default: // must be '=' here.
							display = value;
							break;
					}
					break;

				default:
					System.out.print("Huh?\n");
			}
		}
	}

	// ----------------------------------------------------------------------------------------
	// Don't translate the stuff below this line! These are just emulating syscalls 5 and 8.
	// ----------------------------------------------------------------------------------------

	static Scanner s = new Scanner(System.in);

	static int read_int() {
		int ret = s.nextInt();
		s.nextLine();
		return ret;
	}

	static void read_string(char[] dest, int len) {
		char[] src = Arrays.copyOfRange(s.nextLine().toCharArray(), 0, len);

		for(int i = 0; i < len; i++)
			dest[i] = src[i];
	}
}
