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

Fs          = require 'fs'
Service     = require '../service/service'
Config      = require '../../core/config'
Database    = require '../../core/database'

class Api extends Service
    @getAllTypes    : () ->
        services    = Fs.readdirSync Config.Paths.Services
        types       = new Array
        for service in services
            if Database.Db.models[service]?
                types.push service
        return types

    @default        : () ->
        do Api.getAllTypes
        return {
            responseParams  :
                'Content-Type'  : 'application/json'
            content         : JSON.stringify do Api.getAllTypes
        }

exports.api = Api