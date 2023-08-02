begin;

drop table if exists regions;
create table if not exists regions (
        "regionID" INTEGER NOT NULL,
        "regionName" VARCHAR(100),
        x FLOAT,
        y FLOAT,
        z FLOAT,
        "xMin" FLOAT,
        "xMax" FLOAT,
        "yMin" FLOAT,
        "yMax" FLOAT,
        "zMin" FLOAT,
        "zMax" FLOAT,
        "factionID" INTEGER,
        nebula INTEGER,
        radius FLOAT,
        PRIMARY KEY ("regionID")
);
insert into regions
    select
         *
    from
        mapRegions r
    where
        -- excludes wormhole systems
        r.regionID < 11000001
        and
        -- exclude jove regions
        r.regionID <> 10000004
        and
        r.regionID <> 10000017
        and
        r.regionID <> 10000019
;

drop table if exists constellations;
create table if not exists constellations (
        "regionID" INTEGER,
        "constellationID" INTEGER NOT NULL,
        "constellationName" VARCHAR(100),
        x FLOAT,
        y FLOAT,
        z FLOAT,
        "xMin" FLOAT,
        "xMax" FLOAT,
        "yMin" FLOAT,
        "yMax" FLOAT,
        "zMin" FLOAT,
        "zMax" FLOAT,
        "factionID" INTEGER,
        radius FLOAT,
        PRIMARY KEY ("constellationID")
);
insert into constellations
    select
        c.*
    from
        mapConstellations c
    join
        regions r
    on
        c.regionID = r.regionID
;

drop table if exists systems;
create table systems (
         solarSystemID integer not null
        ,constellationID integer not null
        ,regionID integer not null
        ,solarSystemName varchar(100) not null
        ,security float not null
        ,x not null
        ,y not null
        ,z not null
        ,primary key (solarSystemID)
);
insert into systems
    select 
         s.solarSystemID
        ,s.constellationID
        ,s.regionID
        ,s.solarSystemName
        ,s.security
        ,s.x / b.radius as x
        ,s.y / b.radius as y
        ,s.z / b.radius as z
    from
        mapSolarSystems s
    join
        mapUniverse b
    on 
        nullif(b.universeName, '') is not null
    join
        regions r
    on
        r.regionID = s.regionID
    order by
        s.solarSystemName asc
;

drop table if exists jumps;
create table if not exists jumps (
        "fromRegionID" INTEGER,
        "fromConstellationID" INTEGER,
        "fromSolarSystemID" INTEGER NOT NULL,
        "toSolarSystemID" INTEGER NOT NULL,
        "toConstellationID" INTEGER,
        "toRegionID" INTEGER,
        PRIMARY KEY ("fromSolarSystemID", "toSolarSystemID")
);
insert into jumps
    select 
        *
    from 
        mapSolarSystemJumps j
    where
        (
        -- exclude jove regions
        fromRegionID <> 10000004
        and
        fromRegionID <> 10000017
        and
        fromRegionID <> 10000019
        )
        and
        (
        -- exclude jove regions
        toRegionID <> 10000004
        and
        toRegionID <> 10000017
        and
        toRegionID <> 10000019
        )
;

drop table if exists systemsSubway;
create table systemsSubway (
         solarSystemID integer not null
        ,constellationID integer not null
        ,regionID integer not null
        ,solarSystemName varchar(100) not null
        ,security float not null
        ,x not null
        ,y not null
        ,z not null
        ,subwayInitiatedFromRegionID integer not null
        ,primary key (subwayInitiatedFromRegionID, solarSystemID)
);

drop table mapSolarsystems;
drop table mapSolarSystemJumps;
drop table mapRegions;
drop table mapConstellations;
drop table mapUniverse;

end;