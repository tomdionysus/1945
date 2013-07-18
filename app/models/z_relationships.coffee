# These are example model relationships and can be removed.

App.Country.hasMany App.State, 'states'
App.State.hasMany App.City, 'cities'

App.City.belongsTo App.State, 'state'
App.State.belongsTo App.Country, 'country'