require_relative 'test_helper'

class AboutComposableObservations < Minitest::Test
  def test_composable_add
    expected_result = 1110
    received = 0
    numbers = [10, 100, 1000]

    RxRuby::Observable.from(numbers).sum.subscribe {|x| received = x }

    assert_equal expected_result, received
  end

  def test_composable_before_and_after
    names = Array(1..6)
    a = ''
    b = ''

    RxRuby::Observable.from(names)
      .do {|x| a += x.to_s }
      .select {|n| n % 2 == 0 }
      .do {|n| b += n.to_s }
      .subscribe

    expected_a = '123456'
    expected_b = '246'
    assert_equal expected_a, a
    assert_equal expected_b, b
  end

  def test_we_wrote_this
    received = []
    names = %w[Bart Marge Wes Linus Erik Matt]

    RxRuby::Observable.from(names)
      .select {|name| name.size <= 4 }
      .subscribe {|name| received.push(name) }

    expected_result = 'Bart,Wes,Erik,Matt'
    assert_equal expected_result, received.join(',')
  end

  def test_converting_events
    received = ''
    names = ["wE", "hOpE", "yOU", "aRe", "eNJoyIng", "tHiS"]

    RxRuby::Observable.from(names)
      .map {|name| name.downcase }
      .subscribe {|name| received += name + ' ' }

    assert_equal "we hope you are enjoying this ", received
  end

  def test_create_a_more_relevant_stream
    received = ''
    mouse_x_movements = [100, 200, 150]
    relative_mouse = RxRuby::Observable.from(mouse_x_movements)
                        .map {|mov| mov - 50 }
                        .subscribe {|mov| received += mov.to_s + ', ' }

    expected_result = '50, 150, 100, '
    assert_equal expected_result, received
  end

  def test_checking_everything
    received = nil
    names = [2,4,6,8]

    RxRuby::Observable.from(names)
      .all? {|n| n.even? }
      .subscribe {|n| received = n }

    expected_result = true
    assert_equal expected_result, received
  end

  def test_composition_means_the_sum_is_greater_than_parts
    received = 0
    numbers = RxRuby::Observable.range(1, 10)

    numbers.select {|n| n > 8 }.sum.subscribe {|sum| received = sum }

    expected_result = 19
    assert_equal expected_result, received
  end
end
