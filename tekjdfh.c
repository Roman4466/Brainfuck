#include <stdio.h>
#define CODESIZE 10000
#define DATASIZE 10000
char code[CODESIZE + 1];
short data[DATASIZE];
unsigned int dp = 0;

/* interpret commands at *code, and stop when a 0 is reached */
void interpret(char *code)
{
    char *loop_begin;
    unsigned int nesting_level;

    for (; *code; code++)
    {
        switch (*code)
        {
        case '<':
            dp--;
            break;
        case '>':
            dp++;
            break;
        case '+':
            data[dp]++;
            break;
        case '-':
            data[dp]--;
            break;
        case '.':
            putchar(data[dp] & 0x00ff);
            fflush(stdout);
            break;
        case ',':
            data[dp] = (unsigned short)getchar();
            break;
        case '[':
            loop_begin = code + 1; /* loop_begin -> start of loop */
            /* find end of loop */
            for (nesting_level = 1; nesting_level;)
            {
                switch (*(++code))
                {
                case '[':
                    nesting_level++;
                    break;
                case ']':
                    nesting_level--;
                    break;
                }
            }
            /* interpret loop */
            *code = 0;
            while (data[dp])
                interpret(loop_begin);
            *code = ']';
            break;
        default:
            break; /* we skip unknown commands to allow comments */
        }
    }
}

int main(int argc, char *argv[])
{
    FILE *srcfile = NULL;

    unsigned int length;
    unsigned int i;
    if (argc < 2)
    {
        printf("Syntax: entry <source file>\n");
        exit(1);
    }
    /* open source file */
    if ((srcfile = fopen(argv[1], "rb")) == NULL)
    {
        printf("ERR: Unable to open source file!\n");
        exit(2);
    }
    /* get length */
    fseek(srcfile, 0, SEEK_END);
    length = ftell(srcfile);
    fseek(srcfile, 0, SEEK_SET);
    /* read source and close */
    fread(code, length, 1, srcfile);
    if (srcfile != NULL)
        fclose(srcfile);
    /* add a 0 to the source code */
    code[length] = 0;
    /* clear data buffer */
    for (i = 0; i < DATASIZE; i++)
        data[i] = 0;
    /* interpret code */
    interpret(code);
    return (0);
}