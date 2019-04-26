# Getting help from your development environment

Although syntax errors are not really bugs, they are a nuisance nevertheless.  For compiled languages such as Fortran, C and C++, you'd have to compile the code to spot the issues.

Integrated development environments such as [Eclipse](http://www.eclipse.org/) can be a great help in this respect.  They will perform a syntactic analysis in the background as you type, and warn you about syntax errors early, saving you the time to build your software.

However, for those of you who prefer to keep things simple and use vim for software development, there are a number of plugins you can benefit from.  Managing vim plugins is quite straightforward using vundle, and below you'll find my personal setup.

~~~~
" setup for Vundle vim plugin manager
set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)
Plugin 'vim-scripts/indentpython.vim'
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'jnurmine/Zenburn'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" setup for Vundle vim plugin manager done
~~~~

When I save a file, its syntax is automatically checked, warnings, and errors are added as annotations.  This often saves time by not having to build or run the software to catch mistakes.

For interpreted languages such as Python a static code analysis is performed, and although this will not catch all errors, it is still worth the setup.

A point to mention about your development environment: use a font for your editor that makes code easy to read.  Some fonts make it hard to distinguish between '0' and 'O', or '1' and 'l', so picking a good one will save time and effort.  Nice examples are [Source Code Pro](https://github.com/adobe-fonts/source-code-pro) developed by Adobe, and [Inconsolata](http://www.levien.com/type/myfonts/inconsolata.html) created by Ralf Levien.
