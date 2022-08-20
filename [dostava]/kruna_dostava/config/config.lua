Config = {}


Config['logovi'] = true  -- stavite false ako ne zelite logove
Config['Webhook'] = "" -- ovde ide vas webhook
Config['CommunityName'] = "Kruna_dostava" -- ime loga
Config['CommunityLogo'] = 'https://cdn.discordapp.com/icons/838115320597446677/a96dc72395659c8d3921bece0ac2039d?size=256' -- logo
Config['Avatar'] = '' -- avatar loga

Config['dostava'] = {
    ['JobName'] = 'dostava',  --ime posla koji vam je potreban da bi ga radili
    ['ActionKey'] = 38, -- E
    ['FinalPayout'] = {
        ['Min'] = 500,
        ['Max'] = 1000
    },
    ['Blips'] = {
        {
            ['x'] = -1177.998,
            ['y'] = -892.051,
            ['z'] = 13.757,
            ['sprite'] = 616,
            ['color'] = 47,
            ['scale'] = 0.75,
            ['label'] = "dostava Center",
        }
    },
    ['Uniforms'] = { 
        ['Male'] = {
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
            ['torso_1'] = 13,   ['torso_2'] = 3,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 11,
            ['pants_1'] = 96,   ['pants_2'] = 0,
            ['shoes_1'] = 10,    ['shoes_2'] = 0,
            ['chain_1'] = 0,    ['chain_2'] = 0,
            ['helmet_1'] = -1,    ['helmet_2'] = 0
        },
        ['Female'] = { -- Promenite ako vam se ne svidja
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
            ['torso_1'] = 13,   ['torso_2'] = 3,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 11,
            ['pants_1'] = 96,   ['pants_2'] = 0,
            ['shoes_1'] = 10,    ['shoes_2'] = 0,
            ['chain_1'] = 0,    ['chain_2'] = 0,
            ['helmet_1'] = -1,    ['helmet_2'] = 0
        } 
    },
    ['Base'] = {
        {
            ['coords'] = vec3(-1177.998, -892.051, 13.757),
        }
    },
    ['Prop'] = {
        ['Model'] = 'prop_cs_cardbox_01',
        ['x'] = -1178.628,
        ['y'] = -887.744,
        ['z'] = 12.807, 
    },
    ['Vehicles'] = {
        ['Spawner'] = {
            ['coords'] = {
                vec3(-1168.39, -882.855, 14.137),
            },
            ['rotation'] = 302.2133,
        },
        ['Deleter'] = vec3(-1172.38, -891.480, 13.907),
        ['Plate'] = "dostava",
        ['Cars'] = {
            'rumpo',
        },
    },
    ['Destinacije'] = { -- ako zelite da dodate jos lokacije dodajete ih ovde vec3(x, y, z)
        vec3(-284.3353, -601.2335, 33.5532),
        vec3(-292.3353, -601.2335, 33.5532),
    },
}