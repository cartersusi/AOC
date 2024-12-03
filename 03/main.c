#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

enum { 
    FALSE = 0,
    TRUE = 1
};
void append(char** str, char* new_str);
char* slice(char* str, int start, int end);
char** split_str(char* str, char delim);

const char* input_file = "input";

int main(void) {
    long res = 0;

    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    size_t read;

    regex_t mul_regex;
    regmatch_t mul_match[1];
    int mul;

    regex_t enabler_regex;
    regmatch_t enabler_match[1];
    int enabler;

    fp = fopen(input_file, "r");
    if (fp == NULL) {
        perror("Error opening file");
        exit(EXIT_FAILURE);
    }

    mul = regcomp(&mul_regex, "mul\\([0-9]+,[0-9]+\\)", REG_EXTENDED);
    if (mul != 0) {
        perror("Regex compilation failed.");
        exit(EXIT_FAILURE);
    }

    u_int8_t enabled = TRUE;
    char* enable = "do()";
    char* disable = "don't()";
    enabler = regcomp(&enabler_regex, "do(n't)?\\(\\)", REG_EXTENDED);
    if (enabler != 0) {
        perror("Regex compilation failed.");
        exit(EXIT_FAILURE);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        char *enabler_line = line;
        char **matches = NULL;
        size_t match_count = 0;

        char* mul_line = malloc(1);
        if (!mul_line) {
            perror("Memory allocation error");
            exit(EXIT_FAILURE);
        }
        mul_line[0] = '\0';
        int start_index = 0;

        int current_index = 0;
        while (!regexec(&enabler_regex, enabler_line, 1, enabler_match, 0)) {
            size_t match_len = enabler_match[0].rm_eo - enabler_match[0].rm_so;
            char *match = malloc(match_len + 1);
            if (!match) {
                perror("Memory allocation error");
                exit(EXIT_FAILURE);
            }
            strncpy(match, enabler_line + enabler_match[0].rm_so, match_len);
            match[match_len] = '\0';

            if (strcmp(match, enable) == 0) {
                enabler_line += enabler_match[0].rm_eo;

                if (enabled != TRUE) {
                    enabled = TRUE;
                    start_index = enabler_match[0].rm_eo + current_index;
                }
            } else if (strcmp(match, disable) == 0) {
                enabler_line += enabler_match[0].rm_eo;

                if (enabled != FALSE) {
                    enabled = FALSE;
                    int end_index = enabler_match[0].rm_so + current_index;
                    char* tmp = slice(line, start_index, end_index);
                    append(&mul_line, tmp);
                    free(tmp);
                }
            } else {
                perror("Invalid match");
                exit(EXIT_FAILURE);
            }

            free(match);
            current_index += enabler_match[0].rm_eo;
        }

        if (enabled == TRUE) {
            int end_index = strlen(line);
            char* tmp = slice(line, start_index, end_index);
            append(&mul_line, tmp);
            free(tmp);
        }

        while (!regexec(&mul_regex, mul_line, 1, mul_match, 0)) {
            size_t match_len = mul_match[0].rm_eo - mul_match[0].rm_so;
            char *match = malloc(match_len + 1);
            if (!match) {
                perror("Memory allocation error");
                exit(EXIT_FAILURE);
            }
            strncpy(match, mul_line + mul_match[0].rm_so, match_len);
            match[match_len] = '\0';

            char **new_matches = realloc(matches, (match_count + 1) * sizeof(char *));
            if (!new_matches) {
                perror("Memory allocation error");
                exit(EXIT_FAILURE);
            }
            matches = new_matches;
            matches[match_count++] = match;

            mul_line += mul_match[0].rm_eo;
        }

        for (size_t i = 0; i < match_count; i++) {
            char *nums = strchr(matches[i], '(') + 1;
            nums[strlen(nums) - 1] = '\0';
            
            char** split_nums = split_str(nums, ',');
            int a = atoi(split_nums[0]);
            int b = atoi(split_nums[1]);
            int result = a * b;
            res += result;
            
            free(matches[i]);
        }
        free(matches);
    }

    printf("Result: %ld\n", res);

    regfree(&mul_regex);
    regfree(&enabler_regex);
    fclose(fp);
    free(line);

    return EXIT_SUCCESS;
}

void append(char** str, char* new_str) {
    size_t len = strlen(*str);
    size_t new_len = strlen(new_str);
    char* new_str2 = realloc(*str, len + new_len + 1);
    if (!new_str2) {
        perror("Memory allocation error");
        exit(EXIT_FAILURE);
    }

    *str = new_str2;
    strcpy(*str + len, new_str);
}

char* slice(char* str, int start, int end) {
    char* new_str = malloc(end - start + 1);
    if (!new_str) {
        perror("Memory allocation error");
        exit(EXIT_FAILURE);
    }

    strncpy(new_str, str + start, end - start);
    new_str[end - start] = '\0';

    return new_str;
}

char** split_str(char* str, char delim) {
    char** parts = malloc(2 * sizeof(char*));
    if (!parts) {
        perror("Memory allocation error");
        exit(EXIT_FAILURE);
    }

    char* delim_pos = strchr(str, delim);
    if (!delim_pos) {
        perror("Delimiter not found");
        exit(EXIT_FAILURE);
    }

    size_t part1_len = delim_pos - str;
    size_t part2_len = strlen(str) - part1_len - 1;
    parts[0] = malloc(part1_len + 1);
    parts[1] = malloc(part2_len + 1);

    if (!parts[0]) {
        perror("Memory allocation error");
        exit(EXIT_FAILURE);
    }
    if (!parts[1]) {
        perror("Memory allocation error");
        exit(EXIT_FAILURE);
    }

    strncpy(parts[0], str, part1_len);
    parts[0][part1_len] = '\0';
    strncpy(parts[1], delim_pos + 1, part2_len);
    parts[1][part2_len] = '\0';

    return parts;
}
