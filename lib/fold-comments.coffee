
range = editor.getSelectedBufferRange() # any range you like
marker = editor.markBufferRange(range)
decoration = editor.decorateMarker(marker, {type: 'line', class: 'my-line-class'})

module.exports = FoldComments =
  config:
    autofold:
      type: 'boolean'
      default: false

  #
  # wow
  #
  activate: (state) ->
    atom.commands.add("atom-workspace", "fold-comments:toggle": @toggle.bind(@))
    atom.commands.add("atom-workspace", "fold-comments:fold-all": => @fold.bind(@))
    atom.commands.add("atom-workspace", "fold-comments:unfold-all": => @unfold.bind(@))

    if atom.config.get('fold-comments.autofold')
      atom.workspace.observeTextEditors (editor) =>
        editor.displayBuffer.tokenizedBuffer.onDidTokenize =>
          @foldAs('fold', editor)

  toggle: -> @foldAs('toggle')

  fold: -> @foldAs('fold')

  unfold: -> @foldAs('unfold')

  foldAs: (mode, editor) ->
    editor ||= atom.workspace.getActiveTextEditor()
    marker = editor.markBufferRange(row)

    eachFoldable = (f) ->
      for row in [0..editor.getLastBufferRow()]
        f(row) if editor.isFoldableAtBufferRow(row) && editor.isBufferRowCommented(row)

    switch mode
      when 'toggle' then eachFoldable (row) -> editor.toggleFoldAtBufferRow(row),
      when 'fold' then eachFoldable (row) -> editor.foldBufferRow(row), editor.decorateMarker(marker, {type: 'line', class: 'folded'}),
      when 'unfold' then eachFoldable (row) -> editor.unfoldBufferRow(row), editor.decorateMarker(marker, {type: 'line', class: ''})
