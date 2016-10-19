crypt_client_read <- function(host = "localhost")
	{
		port <- 32323
		socket <- make.socket(host, port)
		on.exit(close.socket(socket))
		read.socket(socket,loop=TRUE)
	}