\name{goertzel-package}
\alias{goertzel-package}
\docType{package}
\title{
  Calculates individual terms of the discrete Fourier transform using the Goertzel algorithm
}
\description{
  The Goertzel algorithm is faster than using a fast Fourier transform, if only a few Fourier components are requested.
}
\details{
  The package exposes \code{\link{goertzel}}, which evaluates selected
  Fourier terms without computing a full FFT. This is useful for targeted
  tone detection tasks such as DTMF decoding.
}
\author{
Helena Schmidt, <helena.schmidt@ktrask.de>.

Maintainer: Helena Schmidt <helena.schmidt@ktrask.de>
}
\references{
  Description of the Goertzel algorithm on dsplib.org:
  http://en.dsplib.org/content/goertzel.html
}
% Optionally other standard keywords, one per line,
% from the file KEYWORDS in the R documentation.
\keyword{ package
          signal}
\seealso{
  \code{\link[stats]{fft}}
}
\examples{
  sample_rate <- 8000
  sample_count <- 400
  dtmf_low <- c(697, 770, 852, 941)
  dtmf_high <- c(1209, 1336, 1477, 1633)
  frequencies <- c(dtmf_low, dtmf_high)

  set.seed(6)
  time <- (0:(sample_count - 1)) / sample_rate
  signal <- 0.9 * sin(2 * pi * 770 * time) +
    0.9 * sin(2 * pi * 1477 * time) +
    rnorm(sample_count, mean = 0, sd = 0.30)

  bins <- frequencies * sample_count / sample_rate
  response <- goertzel(signal, bins)
  power <- Mod(response) ^ 2

  low_index <- which.max(power[seq_along(dtmf_low)])
  high_index <- which.max(power[length(dtmf_low) + seq_along(dtmf_high)])

  stopifnot(low_index == 2L, high_index == 3L)
}
