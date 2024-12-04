res <- 0
input_file <- "input"
xmas <- "XMAS"
target <- strsplit(xmas, NULL)[[1]]
len_xmas <- length(target)
lx <- len_xmas - 1

data <- do.call(rbind, strsplit(readLines(input_file), ""))
m <- nrow(data)
n <- ncol(data)
size_check <- function(mn, m, n) mn == m * n
stopifnot(size_check(length(data), m, n))

directions <- matrix(
  c(1, 0,   # Horizontal
    0, 1,   # Vertical
    1, -1,  # Diagonal 45°
    1, 1,   # Diagonal 135°
    -1, 1,  # Diagonal 225°
    -1, -1, # Diagonal 315°
    -1, 0,  # Horizontal Backwards
    0, -1   # Vertical Backwards
  ),
  ncol = 2, byrow = TRUE
)


valid_direction <- function(dx, dy, x, y) {
  x_end <- x + (dx * lx)
  y_end <- y + (dy * lx)
  return(
    x > 0 && y > 0 &&
    x_end > 0 && y_end > 0 && #nolint
    x <= n && y <= m &&
    x_end <= n && y_end <= m
  )
}


valid_directions <- function(x, y) {
  dir_valid <- apply(directions, 1, function(dir) {
    valid_direction(dir[1], dir[2], x, y)
  })
  return(which(dir_valid))
}
possible <- lapply(seq_len(m), function(y) {
  lapply(seq_len(n), function(x) {
    list(position = c(x, y), directions = valid_directions(x, y))
  })
})
possible <- unlist(possible, recursive = FALSE)

check_xmas <- function(x, y, dx, dy) {
  positions <- 0:lx
  xs <- x + dx * positions
  ys <- y + dy * positions
  arr <- data[cbind(ys, xs)]
  identical(arr, target)
}

res <- sum(sapply(possible, function(i) {
  sum(sapply(i$directions, function(d) {
    dir <- directions[d, ]
    check_xmas(i$position[1], i$position[2], dir[1], dir[2])
  }))
}))

print(res)
