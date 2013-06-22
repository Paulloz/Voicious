###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

{Errors} = require './errors'

class Database
        constructor: (@dbName, @dbHost, @dbPort, @dbOptions) ->

        connect: () =>
            throw Errors.Error "Database.connect : not implemented"

        insert: () =>
            throw Errors.Error "Database.insert : not implemented"

        update: () =>
            throw Errors.Error "Database.update : not implemented"

        get: () =>
            throw Errors.Error "Database.get : not implemented"

        find: () =>
            throw Errors.Error "Database.find : not implemented"

        search: () =>
            throw Errors.Error "Database.search : not implemented"

        delete: () =>
            throw Errors.Error "Database.delete : not implemented"

        close: () =>
            throw Errors.Error "Database.close : not implemented"

exports.Database = Database
