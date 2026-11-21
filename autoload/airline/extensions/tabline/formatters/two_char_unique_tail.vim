" two_char_unique_tail.vim
"
" Standalone vim-airline tabline formatter.
" Derived from vim-airline tabline formatter code (MIT License).
" The formatting algorithm below is intentionally kept functionally aligned
" with the previously used standalone file.

scriptencoding utf-8

let s:skip_symbol = '…'
let s:path_component_length = 2


" ------------------------------------------------------------
" Default formatting with 2-character path shortening
" ------------------------------------------------------------

function! s:default_format(bufnr, buffers) abort
  let l:fnametruncate =
        \ get(g:, 'airline#extensions#tabline#fnametruncate', 0)

  let l:fmod =
        \ get(g:, 'airline#extensions#tabline#fnamemod', ':~:.')

  let l:name = bufname(a:bufnr)

  if empty(l:name)
    let l:display_name = '[No Name]'

  elseif l:name =~# 'term://'
    " Preserve vim-airline terminal-buffer handling.
    let l:display_name =
          \ substitute(l:name, '\(term://\).*\(.*\)', '\1 \2', '')

  else
    let l:display_name = fnamemodify(l:name, l:fmod)

    if get(g:, 'airline#extensions#tabline#fnamecollapse', 1)
      let l:display_name =
            \ pathshorten(l:display_name, s:path_component_length)
    endif

    if a:bufnr != bufnr('%')
          \ && l:fnametruncate
          \ && strchars(l:display_name) > l:fnametruncate

      let l:display_name =
            \ airline#util#strcharpart(
            \   l:display_name,
            \   0,
            \   l:fnametruncate
            \ )
    endif
  endif

  return airline#extensions#tabline#formatters#default#wrap_name(
        \ a:bufnr,
        \ l:display_name
        \ )
endfunction


" ------------------------------------------------------------
" Main formatter
"
" Based on vim-airline unique_tail_improved.
" ------------------------------------------------------------

function! airline#extensions#tabline#formatters#two_char_unique_tail#format(
      \ bufnr,
      \ buffers
      \ ) abort

  " No filename comparison is needed with one or fewer buffers.
  if len(a:buffers) <= 1
    return s:default_format(a:bufnr, a:buffers)
  endif

  let l:curbuf_tail = fnamemodify(bufname(a:bufnr), ':t')
  let l:do_deduplicate = 0
  let l:path_tokens = {}

  " ----------------------------------------------------------
  " Find other buffers having the same filename.
  " ----------------------------------------------------------

  for l:nr in a:buffers
    let l:name = bufname(l:nr)

    if !empty(l:name)
          \ && l:nr != a:bufnr
          \ && fnamemodify(l:name, ':t') ==# l:curbuf_tail

      let l:do_deduplicate = 1

      let l:tokens = reverse(
            \ split(
            \   substitute(
            \     fnamemodify(l:name, ':p:h'),
            \     '\\',
            \     '/',
            \     'g'
            \   ),
            \   '/'
            \ )
            \ )

      let l:token_index = 0

      for l:token in l:tokens
        if l:token ==# ''
          continue
        endif

        if l:token ==# '.'
          break
        endif

        if !has_key(l:path_tokens, l:token_index)
          let l:path_tokens[l:token_index] = {}
        endif

        let l:path_tokens[l:token_index][l:token] = 1
        let l:token_index += 1
      endfor
    endif
  endfor


  " ----------------------------------------------------------
  " If the filename is already unique, use 2-character
  " path shortening.
  " ----------------------------------------------------------

  if !l:do_deduplicate
    return s:default_format(a:bufnr, a:buffers)
  endif


  " ----------------------------------------------------------
  " Build path information used to distinguish duplicate names.
  " ----------------------------------------------------------

  let l:path = []
  let l:token_index = 0

  let l:current_tokens = reverse(
        \ split(
        \   substitute(
        \     fnamemodify(bufname(a:bufnr), ':p:h'),
        \     '\\',
        \     '/',
        \     'g'
        \   ),
        \   '/'
        \ )
        \ )

  for l:token in l:current_tokens
    if l:token ==# '.'
      break
    endif

    let l:duplicated = 0
    let l:uniq = 1
    let l:single = 1

    if has_key(l:path_tokens, l:token_index)
      let l:duplicated = 1

      if len(keys(l:path_tokens[l:token_index])) > 1
        let l:single = 0
      endif

      if has_key(l:path_tokens[l:token_index], l:token)
        let l:uniq = 0
      endif
    endif

    call insert(l:path, {
          \ 'token': l:token,
          \ 'duplicated': l:duplicated,
          \ 'uniq': l:uniq,
          \ 'single': l:single
          \ })

    let l:token_index += 1
  endfor


  " ----------------------------------------------------------
  " Construct the shortest unique buffer name.
  " ----------------------------------------------------------

  let l:buf_name = [l:curbuf_tail]
  let l:has_uniq = 0
  let l:has_skipped = 0

  for l:token_info in reverse(l:path)

    if !l:token_info.duplicated && len(l:buf_name) > 1
      call insert(l:buf_name, s:skip_symbol)
      let l:has_skipped = 0
      break
    endif

    if l:has_uniq
      call insert(l:buf_name, s:skip_symbol)
      let l:has_skipped = 0
      break
    endif

    if !l:token_info.uniq && l:token_info.single
      let l:has_skipped = 1

    else
      if l:has_skipped
        call insert(l:buf_name, s:skip_symbol)
        let l:has_skipped = 0
      endif

      call insert(l:buf_name, l:token_info.token)
    endif

    if l:token_info.uniq
      let l:has_uniq = 1
    endif
  endfor

  if l:has_skipped
    call insert(l:buf_name, s:skip_symbol)
  endif

  return airline#extensions#tabline#formatters#default#wrap_name(
        \ a:bufnr,
        \ join(l:buf_name, '/')
        \ )
endfunction
