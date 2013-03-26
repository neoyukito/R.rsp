###########################################################################/**
# @RdocDefault compileMarkdown
#
# @title "Compiles a Markdown file"
#
# \description{
#  @get "title" to HTML.
# }
#
# @synopsis
#
# \arguments{
#   \item{filename, path}{The filename and (optional) path of the
#      Markdown document to be compiled.}
#   \item{...}{Additional arguments passed to @see "markdown::markdownToHTML".}
#   \item{outPath}{The output and working directory.}
#   \item{verbose}{See @see "R.utils::Verbose".}
# }
#
# \value{
#   Returns (invisibly) the pathname of the generated HTML document.
# }
#
# @author
#
# \seealso{
#   Internally, @see "markdown::markdownToHTML" is used.
# }
#
# @keyword file
# @keyword IO
# @keyword internal
#*/###########################################################################
setMethodS3("compileMarkdown", "default", function(filename, path=NULL, ..., outPath=".", verbose=FALSE) {
  # Load the package (super quietly), in case R.rsp::nnn() was called.
  suppressPackageStartupMessages(require("markdown", quietly=TRUE)) || throw("Package not loaded: markdown");

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Validate arguments
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Arguments 'filename' & 'path':
  pathname <- Arguments$getReadablePathname(filename, path=path);

  # Arguments 'outPath':
  outPath <- Arguments$getWritablePath(outPath);
  if (is.null(outPath)) outPath <- ".";

  # Argument 'verbose':
  verbose <- Arguments$getVerbose(verbose);
  if (verbose) {
    pushState(verbose);
    on.exit(popState(verbose));
  }


  verbose && enter(verbose, "Compiling Markdown document");
  pathname <- getAbsolutePath(pathname);
  verbose && cat(verbose, "Markdown pathname (absolute): ", pathname);
  verbose && printf(verbose, "Input file size: %g bytes\n", file.info(pathname)$size);
  verbose && cat(verbose, "Output and working directory: ", getAbsolutePath(outPath));
  pattern <- "(.*)[.]([^.]+)$";
  replace <- "\\1.html";
  filenameOut <- gsub(pattern, replace, basename(pathname));
  pathnameOut <- filePath(outPath, filenameOut);
  verbose && cat(verbose, "Output pathname: ", getAbsolutePath(pathnameOut));

  opwd <- ".";
  on.exit(setwd(opwd), add=TRUE);
  if (!is.null(outPath)) {
    opwd <- setwd(outPath);
  }

  verbose && enter(verbose, "Calling markdown::markdownToHTML()");
  pathnameR <- getRelativePath(pathname);
  mdToHTML <- markdown::markdownToHTML;
  userArgs <- list(...);
  keep <- is.element(names(userArgs), names(formals(mdToHTML)));
  userArgs <- userArgs[keep];
  args <- c(list(pathnameR, output=pathnameOut), userArgs);
  res <- do.call(mdToHTML, args=args);
  verbose && exit(verbose);

  setwd(opwd); opwd <- ".";
  verbose && printf(verbose, "Output file size: %g bytes\n", file.info(pathnameOut)$size);

  verbose && exit(verbose);

  invisible(pathnameOut);
}) # compileMarkdown()


############################################################################
# HISTORY:
# 2013-03-25
# o Created (from compileLaTeX.R).
############################################################################