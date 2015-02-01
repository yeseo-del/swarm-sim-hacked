'use strict'

###*
 # @ngdoc filter
 # @name swarmApp.filter:bignum
 # @function
 # @description
 # # bignum
 # Filter in the swarmApp.
###
angular.module('swarmApp').factory 'bignumFormatter', (options) ->
  (suffixes_, opts={}) ->
    opts.sigfigs ?= 3
    # special case: 99k or less looks nicer with the 'k' omitted
    opts.minsuffix ?= 1e5
    (num, floorlimit=0) ->
      suffixes = suffixes_
      if !num
        return num
      try
        num = new Decimal num
      catch
        num = new Decimal num.toPrecision 15
      if num.isZero()
        return num+''
      if num.lessThan floorlimit
        return num.toPrecision(opts.sigfigs).replace /\.?0+$/, ''
      num = num.floor()
      if num.lessThan opts.minsuffix
        # sadly, num.toLocaleString() does not work in unittests. node vs browser?
        # toLocaleString would be nice for foreign users, but my unittests are
        # more important, sorry. Maybe later.
        return numeral(num.toNumber()).format '0,0'
      # http://mathforum.org/library/drmath/view/59154.html
      #index = num.log().dividedToIntegerBy(Decimal.log 1000)
      # Decimal.log() is too slow for large numbers. Docs say performance degrades exponentially as # digits increases, boo.
      # Lucky me, the length is used by decimal.js internally: num.e
      # this is in the docs, so I think it's stable enough to use...
      index = Math.floor num.e / 3

      if options.notation() == 'hybrid'
        # hybrid is like standard, but switches to scientific notation sooner: shorter suffix list
        suffixes = suffixes.slice 0, 12
      if options.notation() == 'scientific-e' or index >= suffixes.length
        # no suffix, use scientific notation. No grouping in threes or suffixes; quit early.
        # round down for consistency with suffixed formats, though rounding doesn't matter so much here.
        return num.toExponential(opts.sigfigs-1, Decimal.ROUND_FLOOR).replace 'e+', 'e'
      if options.notation() == 'engineering'
        # Engineering works like standard, but with number-based suffixes instead of a hardcoded list
        suffix = "E#{index * 3}"
      else
        # use standard-decimal's suffix list
        suffix = suffixes[index]
      num = num.dividedBy Decimal.pow 1000, index
      # regex removes trailing zeros and decimal
      # based on http://stackoverflow.com/a/16471544
      #return "#{num.toPrecision(3).replace(/\.([^0]*)0+$/, '.$1').replace(/\.$/, '')}#{suffix}"
      # turns out it's very distracting to have the number length change, so keep trailing zeros.
      # always round down to fix #245
      return "#{num.toPrecision(opts.sigfigs, Decimal.ROUND_FLOOR)}#{suffix}"

angular.module('swarmApp').filter 'bignum', (bignumFormatter) ->
  # These aren't official abbreviations, apparently, can't find them on google
  # for anything but cookie clicker. Other games have used them though.
  bignumFormatter ['', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No',
                   # I made up these larger abbrevs, but some of them match derivative clicker (from memory). Oh well.
                   # decillion, vigintillion, trigintillion, quadragintillion, quinquagintillion,
                   'Dc', 'UDc', 'DDc', 'TDc', 'QaDc', 'QiDc', 'SxDc', 'SpDc', 'ODc', 'NDc'
                   'Vi', 'UVi', 'DVi', 'TVi', 'QaVi', 'QiVi', 'SxVi', 'SpVi', 'OVi', 'NVi'
                   'Tg', 'UTg', 'DTg', 'TTg', 'QaTg', 'QiTg', 'SxTg', 'SpTg', 'OTg', 'NTg'
                   'Qd', 'UQd', 'DQd', 'TQd', 'QaQd', 'QiQd', 'SxQd', 'SpQd', 'OQd', 'NQd'
                   'Qq', 'UQq', 'DQq', 'TQq', 'QaQq', 'QiQq', 'SxQq', 'SpQq', 'OQq', 'NQq'
                   # sexagintillion, septuagintillion, octogintillion, [Number.MAX_VALUE]
                   'Sx', 'USx', 'DSx', 'TSx', 'QaSx', 'QiSx', 'SxSx', 'SpSx', 'OSx', 'NSx'
                   'Sp', 'USp', 'DSp', 'TSp', 'QaSp', 'QiSp', 'SxSp', 'SpSp', 'OSp', 'NSp'
                   'Oc', 'UOc', 'DOc', 'TOc', 'QaOc', 'QiOc', 'SxOc', 'SpOc', 'OOc', 'NOc'
                  ]

angular.module('swarmApp').filter 'longnum', (bignumFormatter) ->
  # http://home.kpn.nl/vanadovv/BignumbyN.html
  # http://mathforum.org/library/drmath/view/59154.html
  bignumFormatter [''
                   ' thousand'
                   ' million'
                   ' billion'
                   ' trillion'
                   ' quadrillion'
                   ' quintillion'
                   ' sextillion'
                   ' septillion'
                   ' octillion'
                   ' nonillion'
                   ' decillion'
                   ' undecillion'
                   ' duodecillion'
                   ' tredecillion'
                   ' quattuordecillion'
                   ' quinquadecillion'
                   ' sedecillion' # google says this is actually legit, not a typo for 'sexdecillion'
                   ' septendecillion'
                   ' octodecillion'
                   ' novendecillion'
                   ' vigintillion'
                   ' unvigintillion'
                   ' duovigintillion'
                   ' tresvigintillion'
                   ' quattuorvigintillion'
                   ' quinquavigintillion'
                   ' sesvigintillion'
                   ' septemvigintillion'
                   ' octovigintillion'
                   ' novemvigintillion'
                   ' trigintillion'
                   ' untrigintillion'
                   ' duotrigintillion'
                   ' trestrigintillion'
                   ' quattuortrigintillion'
                   ' quinquatrigintillion'
                   ' sestrigintillion'
                   ' septentrigintillion'
                   ' octotrigintillion'
                   ' noventrigintillion'
                   ' quadragintillion'
                   ' unquadragintillion'
                   ' duoquadragintillion'
                   ' tresquadragintillion'
                   ' quattuorquadragintillion'
                   ' quinquaquadragintillion'
                   ' sesquadragintillion'
                   ' septenquadragintillion'
                   ' octoquadragintillion'
                   ' novenquadragintillion'
                   ' quinquagintillion'
                   ' unquinquagintillion'
                   ' duoquinquagintillion'
                   ' tresquinquagintillion'
                   ' quattuorquinquagintillion'
                   ' quinquaquinquagintillion'
                   ' sesquinquagintillion'
                   ' septenquinquagintillion'
                   ' octoquinquagintillion'
                   ' novenquinquagintillion'
                   ' sexagintillion'
                   ' unsexagintillion'
                   ' duosexagintillion'
                   ' tresexagintillion'
                   ' quattuorsexagintillion'
                   ' quinquasexagintillion'
                   ' sesexagintillion'
                   ' septensexagintillion'
                   ' octosexagintillion'
                   ' novensexagintillion'
                   ' septuagintillion'
                   ' unseptuagintillion'
                   ' duoseptuagintillion'
                   ' treseptuagintillion'
                   ' quattuorseptuagintillion'
                   ' quinquaseptuagintillion'
                   ' seseptuagintillion'
                   ' septenseptuagintillion'
                   ' octoseptuagintillion'
                   ' novenseptuagintillion'
                   ' octogintillion'
                   ' unoctogintillion'
                   ' duooctogintillion'
                   ], {sigfigs:6, minsuffix:1e6}

angular.module('swarmApp').filter 'ceil', ->
  (num) -> Math.ceil num

angular.module('swarmApp').filter 'percent', ($filter) ->
  (num, opts={}) ->
    if _.isNumber opts
      opts = {places:opts}
    opts.places ?= 0
    try
      dec = new Decimal num
    catch
      dec = new Decimal num.toPrecision(15)
    if opts.plusOne
      dec = dec.minus(1)
    dec = dec.times(100)
    if opts.floor
      dec = dec.floor()
    if opts.longnum
      dec = $filter('longnum')(dec)
    else
      dec = $filter('number')(dec.toNumber(), opts.places)
    return "#{dec}%"
