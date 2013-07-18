# Default Specification file. 
#
# All specification files should be named [name]-spec.coffee

describe "Default Specification", ->
  it 'should run specs', ->
    expect(true).toBeTruthy()

    expect(App.G1945GameView.flipYAngle(5)).toEqual(175)
    expect(App.G1945GameView.flipYAngle(85)).toEqual(95)
    expect(App.G1945GameView.flipYAngle(185)).toEqual(355)
    expect(App.G1945GameView.flipYAngle(355)).toEqual(185)