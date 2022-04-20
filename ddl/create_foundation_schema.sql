CREATE DATABASE gen_db
    WITH 
    OWNER = ebsadm
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE gen_db
    IS 'This is a demo database for storing generation and imagery data. All data is fabricated.';

CREATE  TABLE "public".power_plant ( 
	id                   serial  NOT NULL  ,
	name                 text  NOT NULL  ,
	latitude             double precision    ,
	longitude            double precision    ,
	CONSTRAINT pk_power_plant PRIMARY KEY ( id )
 );

CREATE  TABLE "public".generation_unit ( 
	id                   serial  NOT NULL  ,
	name                 text  NOT NULL  ,
	generation_reporting_id integer  NOT NULL  ,
	capacity             double precision  NOT NULL  ,
	fuel_type            text    ,
	prime_mover          text    ,
	plant_id             integer    ,
	CONSTRAINT pk_generation_unit PRIMARY KEY ( id ),
	CONSTRAINT unq_generation_unit_generation_reporting_id UNIQUE ( generation_reporting_id ) 
 );

CREATE  TABLE "public".imagery ( 
	id                   serial  NOT NULL  ,
	latitude             double precision    ,
	longitude            double precision    ,
	plant_id             integer  NOT NULL  ,
	created_on           timestamp  NOT NULL  ,
	cloud_fraction       double precision  NOT NULL  ,
	image_path           text  NOT NULL  ,
	CONSTRAINT pk_imagery PRIMARY KEY ( id )
 );

CREATE  TABLE "public".generation ( 
	id                   serial  NOT NULL  ,
	generation_reporting_id integer  NOT NULL  ,
	generation           double precision  NOT NULL  ,
	time_covered         timestamp(12)  NOT NULL  ,
	CONSTRAINT pk_generation PRIMARY KEY ( id )
 );

ALTER TABLE "public".generation ADD CONSTRAINT fk_generation_generation_unit FOREIGN KEY ( generation_reporting_id ) REFERENCES "public".generation_unit( generation_reporting_id );

ALTER TABLE "public".generation_unit ADD CONSTRAINT fk_generation_unit_power_plant FOREIGN KEY ( plant_id ) REFERENCES "public".power_plant( id );

ALTER TABLE "public".imagery ADD CONSTRAINT fk_imagery_power_plant FOREIGN KEY ( plant_id ) REFERENCES "public".power_plant( id );

COMMENT ON TABLE "public".power_plant IS 'A power plant is usually made up of several independent generation units. For example, a power plant might have a large coal fired unit and a combined cycle natural gas unit. This table stores power plant data. You''ll find its generation units data in the linked generation_unit table.';

COMMENT ON COLUMN "public".power_plant.id IS 'Auto-incrementing primary key.';

COMMENT ON COLUMN "public".power_plant.name IS 'The power plant name.';

COMMENT ON COLUMN "public".power_plant.latitude IS 'The latitude coordinate of the geographic location of the power plant.';

COMMENT ON COLUMN "public".power_plant.longitude IS 'The longitude coordinate of the geographic location of the power plant.';

COMMENT ON CONSTRAINT unq_generation_unit_generation_reporting_id ON "public".generation_unit IS 'Unique generation reporting ID for generation data to link to.';

COMMENT ON TABLE "public".generation_unit IS 'The generation unit of a power plant. Multiple generation units can link to the same power plant.';

COMMENT ON COLUMN "public".generation_unit.id IS 'Auto-incrementing primary key.';

COMMENT ON COLUMN "public".generation_unit.name IS 'The name of the generation unit.';

COMMENT ON COLUMN "public".generation_unit.generation_reporting_id IS 'The reporting ID linked to the generation data. See generation table.';

COMMENT ON COLUMN "public".generation_unit.capacity IS 'Capacity of the the generation unit in megawatts.';

COMMENT ON COLUMN "public".generation_unit.fuel_type IS 'The type of fuel of this generation unit.';

COMMENT ON COLUMN "public".generation_unit.prime_mover IS 'The prime mover of this generation unit.';

COMMENT ON COLUMN "public".generation_unit.plant_id IS 'The ID of the power plant this generation unit belongs to.';

COMMENT ON TABLE "public".imagery IS 'Each row is a 3km x 3km patch centered on each power plant, which gives us an image of each power plant every 5 days or so (determined by the revisit rate of the satellite(s)). The images are about 2MB each.';

COMMENT ON COLUMN "public".imagery.id IS 'Auto-incrementing primary key.';

COMMENT ON COLUMN "public".imagery.latitude IS 'The latitude coordinate of this image.';

COMMENT ON COLUMN "public".imagery.longitude IS 'The longitude coordinate of this image.';

COMMENT ON COLUMN "public".imagery.plant_id IS 'The ID of the plant that is centered in this image.';

COMMENT ON COLUMN "public".imagery.created_on IS 'Timestamp on when this image was captured.';

COMMENT ON COLUMN "public".imagery.cloud_fraction IS 'The fraction of the image that contains clouds.';

COMMENT ON COLUMN "public".imagery.image_path IS 'This is a URL/path of the location of the actual image. For the purposes of this exercise, this architecture stores images on AWS S3.';

COMMENT ON TABLE "public".generation IS 'This table contains generation data, ie. power generation per generation unit per hour.';

COMMENT ON COLUMN "public".generation.id IS 'Auto-incrementing primary key.';

COMMENT ON COLUMN "public".generation.generation_reporting_id IS 'The reporting ID linked to the generation unit this generation data belongs to.';

COMMENT ON COLUMN "public".generation.generation IS 'The average megawatts during the hour as indicated in the time_covered column.';

COMMENT ON COLUMN "public".generation.time_covered IS 'Timestamp indicating the date/time this generation data covers.';
