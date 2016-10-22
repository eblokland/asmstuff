#include <stdio.h>
#include <stdlib.h>

#define STRLEN(x) ((sizeof(x) / sizeof((x)[0]))-1) //defines STRLEN as the number of characters in the array (minus one to remove the null character at the end)

void splitnum(unsigned short toinsert, unsigned char * destination){
    *(destination) = toinsert >> 8; //bit shifts the short by 8 bits so the least significant 8 are now the most significant 8
    *(destination + 1) = toinsert; //chops off the most significant
    return;
}

unsigned short fixmyshit(unsigned char * beginning){
    return ((*(beginning) << 8) + *(beginning + 1));
}

int charIsValid(char c){
    return (c == '[' || c == ']' || c == '+' || c == '-' || c == '<' || c == '>' || c == ',' || c == '.');
}


void strparser (char toparse[], unsigned char * destination){
    //format = 'op' + 2byte offset
    int i = 0;
    int depth = 0;
    int itemp;
    char lastchar;
   unsigned short int offset = 1; //start the 16 bit offset as 1
    
    //even though the splitnum function call is likely to add time, i left it in since the parser does not run as long as the rest of the program.  will probably do in-line in assembly though.
    while (toparse[i] != 0){ //until a null terminator is reached in the string
        switch(toparse[i]){ //check the current character
            case '<' :
                while(toparse[i+1] == '<' || (!charIsValid(toparse[i+1]) && toparse[i+1] != 0)){ //for each additional <, add one to the offset
                    if(toparse[i + 1] == '<') offset++; //should only increase offset if correct char.
                    i++; //increment the instruction counter
                }
                *destination = '<'; //duh
                splitnum(offset, destination + 1);
                break;
            case '>' :
                while(toparse[i+1] == '>' || (!charIsValid(toparse[i+1])&& toparse[i+1] != 0)){ //same thing but for >
                    if(toparse[i+1] == '>')offset++;
                    i++;
                }
                *destination = '>';
                splitnum(offset, destination +1);
                break;
            case '+' :
                while(toparse[i+1] == '+' || (!charIsValid(toparse[i+1])&& toparse[i+1] != 0)){ //same thing but for +
                    if(toparse[i+1] == '+')offset++;
                    i++;
                }
                *destination = '+';
                splitnum(offset, destination + 1);
                break;
            case '-' :
                while(toparse[i+1] == '-' || (!charIsValid(toparse[i+1])&& toparse[i+1] != 0)){ //you get the point
                    if(toparse[i+1] == '-')offset++;
                    i++;
                }
                *destination = '-';
                splitnum(offset, destination + 1);
                break;
            case ',' :
                while(toparse[i+1] == ',' || (!charIsValid(toparse[i+1])&& toparse[i+1] != 0)){//no shit
                    if(toparse[i+1] == ',')offset++;
                    i++;
                }
                *destination = ',';
                splitnum(offset, destination + 1);
                break;
            case '.' :
                while(toparse[i+1] == '.' || (!charIsValid(toparse[i+1]) && toparse[i+1] != 0)){//your mum
                    if(toparse[i+1] == '.')offset++;
                    i++;
                }
                *destination = '.';
                splitnum(offset, destination + 1);
                break;
            case '[' :
                depth = 1;//set initial depth to 1
                itemp = i; //temporary i for iterating back and forth without messing with the actual order of ops
                lastchar = 0; // initialize the buffer for lastchar with a null pointer (since that shouldn't appear as the last char)
                while(depth > 0){ //until a matching ] is found
                    if(toparse[itemp+1] == '[') depth++; //if another [ is found, add 1 to buffer
                    else if(toparse[itemp+1] == ']'){ //if a ] is found, decrement depth, and check if it is the matching bracket.  if it is, then break out of the loop.
                        depth--; //no shit
                        if(depth == 0) break;
                    }
                    if(toparse[itemp+1] == '[' || toparse[itemp+1] == ']' || ((lastchar != toparse[itemp+1]) && (charIsValid(toparse[itemp+1])))){ // make sure that non-valid chars don't interfere with the offset.  also, [ and ] each have their own entry so they should cause
                                    //an offset++ every time they're seen.
                            offset++;
                            lastchar = toparse[itemp+1]; //store the new character to test against in the lastchar buffer.
                    }
                    itemp++;//increment instruction pointer
                }
                *destination = '['; //once done with the loop, do this.
                
                //trying to put a 16 bit number into a char * leads to it being cut off.  we need to convert the number into 2 8 bit numbers then reassemble it
                //this should not be necessary when programming in assembly
                splitnum(offset, destination + 1);
                break;
            case ']' :
                itemp = i;//init itemp, depth, and lastchar again
                depth = 1;
                lastchar = 0;
                while(depth > 0){ //same deal with depth
                    if(toparse[itemp-1] == '['){ //we're going in reverse this time so it'll be itemp-1 instead of +1
                        depth--;
                        if(depth == 0) break;//same break logic here.  if the matching [ is found then break.
                    }
                    else if(toparse[itemp - 1] == ']'){
                        depth++;//need to add depth since there was another ]
                    }
                    if(toparse[itemp-1] == '[' || toparse[itemp-1] == ']' || ((lastchar != toparse[itemp-1]) && charIsValid(toparse[itemp-1])) ){
                        offset++; //fat if statement again
                        lastchar = toparse[itemp-1];//bugs on bugs on bugs
                    }
                    itemp--;//decrement temporaryinstruction pointer before restarting the loop
                }
                *destination = ']';//yep
                splitnum(offset, destination + 1);

                break;
        }
        i++; //increment the current instruction
        if(*destination != 0){ //don't advance the destination pointer if there was no character to insert (i.e. there was an invalid char present)
            destination = destination + 3; //increase by 3 bytes i hope.
        }
        offset = 1;//reset offset for the next run of the loop
    }
    *destination = 0; //end with a null
    return;//we're done
}






int main(){
    //program goes here.
    char program[] = "[]++++++++++[>>+>+>++++++[<<+<+++>>>-]<<<<-][>>+<<]>[>>]<<<<[>++<[-]]>.>.";
    unsigned char * parsed = malloc((STRLEN(program) * 3) + 1);
    strparser(program, parsed);
    //IMPLEMENT REALLOC LATER
    signed char * tapebegin = calloc(30000, sizeof(signed char));
    signed char * tapeptr = tapebegin;
    int tempint = 0;
    
    //doing the reassembly of the offset in-line is significantly faster than doing with a function call, so i copy-pasted the code from the one line function in.  probably should do the same thing in assembly.
    while(*parsed != 0){
        switch (*parsed){
                
            case '<' :
                tapeptr += (sizeof(signed char) * (((*(parsed+1) << 8) + *(parsed + 2))));
                break;
            case '>' :
                tapeptr = tapeptr - (sizeof(signed char) * (((*(parsed+1) << 8) + *(parsed + 2))));
                break;
            case '+' :
                *tapeptr = *tapeptr + (((*(parsed+1) << 8) + *(parsed + 2)));
                break;
            case '-':
                *tapeptr = *tapeptr - ((*(parsed+1) << 8) + *(parsed + 2));
                break;
            case '.' :
                tempint = ((*(parsed+1) << 8) + *(parsed + 2));
                for(int i = 0; i < tempint; i++){
                printf("%c", *tapeptr);
                }
                break;
            case ',' :
                tempint = ((*(parsed+1) << 8) + *(parsed + 2));
                for(int i = 0; i < tempint; i++){
                scanf("%c", tapeptr);
                }
                break;
                
            case '[' :
                if(*tapeptr == 0){
                    parsed = parsed + (((*(parsed+1) << 8) + *(parsed + 2)) * 3);
                }
                else;
                break;
            case ']' :
                if(*tapeptr !=0){
                    //parsed = parsed - (((*(parsed +1) << 8) + *(parsed + 2)) * 3);
                    parsed = parsed - (((*(parsed+1) << 8) + *(parsed + 2)) *3);
                }
                else;
                break;
            
        }	
        parsed = parsed + 3;  //increment pointer by 3 bytes, does correct thing for bracket cases.
        
        
    }
    
    //free(tapebegin);  //this fucks things up but i don't know why, right now allocated memory is not being freed (but the program ends anyway)
    return 0;
}

