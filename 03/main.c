#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

#define NullError(x, msg) if(!x) { perror(msg); goto cleanup; }
#define RegexError(x, msg) if(x != 0) { perror(msg); goto cleanup; }
#define FreeArr(x, xlen) for (size_t i = 0; i < xlen; i++) { free(x[i]); } free(x);

enum { 
    FALSE = 0,
    TRUE = 1
};
const char* input_file = "input";
const char* enable = "do()";
const char* disable = "don't()";

typedef struct {
    regex_t regex;
    regmatch_t match[1];
    int compiled;
} regex;
regex NewRegex(char* _pattern);

char* Empty();
char* Slice(char* _str, int _start, int _end);
char** SplitString(char* _str, char _delim);
char* Matching(regex* _r, char* _line);
int Append(char** _str, char* _new_str);

int main(void) {
    unsigned long long res = 0;

    FILE * fp;
    size_t flen = 0;
    size_t reader;
    fp = fopen(input_file, "r");
    NullError(fp, "File opening failed");

    u_int8_t enabled = TRUE;
    regex mul_regex = NewRegex("mul\\([0-9]+,[0-9]+\\)");
    RegexError(mul_regex.compiled, "Regex compilation failed");
    
    regex enabler_regex = NewRegex("do(n't)?\\(\\)");
    RegexError(enabler_regex.compiled, "Regex compilation failed");

    char* line = Empty();
    NullError(line, "Memory allocation error");
    char** matches = NULL;
    size_t match_count = 0;
    while ((reader = getline(&line, &flen, fp)) != -1) {
        NullError(line, "Memory allocation error");
        
        char* str_builder = Empty();
        NullError(str_builder, "Memory allocation error");
        matches = NULL;
        match_count = 0;

        char* enabler_line = line;
        int start_index = 0;
        int current_index = 0;
        while (!regexec(&enabler_regex.regex, enabler_line, 1, enabler_regex.match, 0)) {
            char* match = Matching(&enabler_regex, enabler_line);
            NullError(match, "Memory allocation error");

            if (strcmp(match, enable) == 0) {
                enabler_line += enabler_regex.match[0].rm_eo;

                if (enabled != TRUE) {
                    enabled = TRUE;
                    start_index = enabler_regex.match[0].rm_eo + current_index;
                }
            } 
            else if (strcmp(match, disable) == 0) {
                enabler_line += enabler_regex.match[0].rm_eo;

                if (enabled != FALSE) {
                    enabled = FALSE;
                    const int end_index = enabler_regex.match[0].rm_so + current_index;
                    
                    char* tmp = Slice(line, start_index, end_index);
                    NullError(tmp, "Memory allocation error");

                    if (Append(&str_builder, tmp) != 0) {
                        goto cleanup;
                    }
                    free(tmp);
                }
            } 
            else {
                perror("Invalid match");
                goto cleanup;
            }

            free(match);
            current_index += enabler_regex.match[0].rm_eo;
        }

        if (enabled == TRUE) {
            const int end_index = strlen(line);

            char* tmp = Slice(line, start_index, end_index);
            NullError(tmp, "Memory allocation error");
            
            if (Append(&str_builder, tmp) != 0) {
                goto cleanup;
            }
            free(tmp);
        }

        char* mul_line = str_builder;
        while (!regexec(&mul_regex.regex, mul_line, 1, mul_regex.match, 0)) {
            char *match = Matching(&mul_regex, mul_line);
            NullError(match, "Memory allocation error");

            char **new_matches = realloc(matches, (match_count + 1) * sizeof(char *));
            NullError(new_matches, "Memory allocation error");

            matches = new_matches;
            matches[match_count++] = match;

            mul_line += mul_regex.match[0].rm_eo;
        }

        char* endptr;
        for (size_t i = 0; i < match_count; i++) {
            char *nums = strchr(matches[i], '(') + 1;
            if (strlen(nums) < 1 || strlen(nums) > 9) {
                perror("Invalid Amount of numbers");
                goto cleanup;
            }
            nums[strlen(nums) - 1] = '\0';
            
            char** split_nums = SplitString(nums, ',');
            NullError(split_nums, "Memory allocation error");

            const unsigned long a = strtoul(split_nums[0], &endptr, 10);
            const unsigned long b = strtoul(split_nums[1], &endptr, 10);
            res += a * b;

            FreeArr(split_nums, 2);
        }

        if (str_builder) {
            free(str_builder);
            str_builder = NULL;
        }
    }
    printf("Result: %llu\n", res);
    
    if (fp) fclose(fp);
    if (line) free(line);
    if (mul_regex.compiled == 0) regfree(&mul_regex.regex);
    if (enabler_regex.compiled == 0) regfree(&enabler_regex.regex);
    if (matches) FreeArr(matches, match_count);
    return EXIT_SUCCESS;
cleanup:
    if (fp) fclose(fp);
    if (line) free(line);
    if (mul_regex.compiled == 0) regfree(&mul_regex.regex);
    if (enabler_regex.compiled == 0) regfree(&enabler_regex.regex);
    if (matches) FreeArr(matches, match_count);
    return EXIT_FAILURE;
}

regex NewRegex(char* _pattern) {
    regex r;
    r.compiled = regcomp(&r.regex, _pattern, REG_EXTENDED);
    return r;
}

char* Empty() {
    char* str = malloc(1);
    NullError(str, "Memory allocation error");

    str[0] = '\0';
    return str;
cleanup:
    free(str);
    return NULL;
}

int Append(char** _str, char* _new_str) {
    const size_t len = strlen(*_str);
    const size_t new_len = strlen(_new_str);
    char* new_str2 = realloc(*_str, len + new_len + 1);
    if (!new_str2) {
        perror("Memory allocation error");
        return -1;
    }

    *_str = new_str2;
    strcpy(*_str + len, _new_str);
    return 0;
}

char* Slice(char* _str, int _start, int _end) {
    if (_end < _start) {
        perror("Invalid slice range: end < start");
        goto cleanup;
    }
    const size_t len = _end - _start;
    char* new_str = malloc(len + 1);
    NullError(new_str, "Memory allocation error");

    strncpy(new_str, _str + _start, len);
    new_str[len] = '\0';

    return new_str;
cleanup:
    free(new_str);
    return NULL;
}

char** SplitString(char* _str, char _delim) {
    char** parts = malloc(2 * sizeof(char*));
    NullError(parts, "Memory allocation error");

    char* delim_pos = strchr(_str, _delim);
    NullError(delim_pos, "No delimiter");

    const size_t part1_len = delim_pos - _str;
    const size_t part2_len = strlen(_str) - part1_len - 1;
    parts[0] = malloc(part1_len + 1);
    parts[1] = malloc(part2_len + 1);

    NullError(parts[0], "Memory allocation error");
    NullError(parts[1], "Memory allocation error");

    strncpy(parts[0], _str, part1_len);
    parts[0][part1_len] = '\0';
    strncpy(parts[1], delim_pos + 1, part2_len);
    parts[1][part2_len] = '\0';

    return parts;
cleanup:
    FreeArr(parts, 2);
    return NULL;
}

char* Matching(regex* _r, char* _line) {
    const size_t match_len = _r->match[0].rm_eo - _r->match[0].rm_so;
    char *match = malloc(match_len + 1);
    NullError(match, "Memory allocation error");
    strncpy(match, _line + _r->match[0].rm_so, match_len);
    match[match_len] = '\0';

    return match;
cleanup:
    free(match);
    return NULL;
}