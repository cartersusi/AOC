```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

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

int main(void) {
    long res = 0;

    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    size_t read;

    regex_t regex;
    regmatch_t patter_match[1];
    int val;

    fp = fopen("input", "r");
    if (fp == NULL) {
        perror("Error opening file");
        exit(EXIT_FAILURE);
    }

    val = regcomp(&regex, "mul\\([0-9]+,[0-9]+\\)", REG_EXTENDED);
    //enabler = regcomp(&enabler_regex, "do(n't)?\\(\\)", REG_EXTENDED);
    if (val != 0) {
        perror("Regex compilation failed.");
        exit(EXIT_FAILURE);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        char *tmp = line;
        char **matches = NULL;
        size_t match_count = 0;

        while (!regexec(&regex, tmp, 1, patter_match, 0)) {
            size_t match_len = patter_match[0].rm_eo - patter_match[0].rm_so;
            char *match = malloc(match_len + 1);
            if (!match) {
                perror("Memory allocation error");
                exit(EXIT_FAILURE);
            }
            strncpy(match, tmp + patter_match[0].rm_so, match_len);
            match[match_len] = '\0';

            char **new_matches = realloc(matches, (match_count + 1) * sizeof(char *));
            if (!new_matches) {
                perror("Memory allocation error");
                exit(EXIT_FAILURE);
            }
            matches = new_matches;
            matches[match_count++] = match;

            tmp += patter_match[0].rm_eo;
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

    puts("Result: ");
    printf("%ld\n", res);

    regfree(&regex);
    fclose(fp);
    free(line);

    return EXIT_SUCCESS;
}
```