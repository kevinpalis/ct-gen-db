
--fix lats out of bounds
update power_plant 
set latitude = (random() * 181 + -90)
where latitude>90 or latitude<-90;
--fix long out of bounds
update power_plant 
set longitude = (random() * 361 + -180)
where longitude>180 or longitude<-180;
--check
select * from power_plant;


--get all coal generation units with capacity greater than 100MW in the US
--bounding box from PatrikHlobil's answer on this thread https://gist.github.com/graydon/11198540
select * from generation_unit u join power_plant p on u.plant_id=p.id where u.capacity > 100 and u.fuel_type='coal'
and (p.latitude between 24.9493 and 49.5904) and (p.longitude between -125.0011 and -66.9326);

--create view of all generation units in the US (uses simple bounding box)
--bounding box from PatrikHlobil's answer on this thread https://gist.github.com/graydon/11198540
create or replace view v_generation_units_usa as
select u.*, p.name as plant_name, p.latitude, p.longitude from generation_unit u join power_plant p on u.plant_id=p.id where
(p.latitude between 24.9493 and 49.5904) and (p.longitude between -125.0011 and -66.9326);
--all coal generation units in the USA
select * from v_generation_units_usa where fuel_type='coal';

--get info for all coal generation units greater than 100MW in the US (with generation_reporting_id) = returns 996 rows on test data
select i.created_on, i.image_path, i.cloud_fraction, gu.plant_id, gu.id as generation_id, gu.generation_reporting_id from imagery i join v_generation_units_usa gu
on i.plant_id=gu.plant_id where gu.fuel_type='coal' and gu.capacity>100;

--get info for all coal generation units greater than 100MW in the US (with the actual generation data) = returns 10033 rows on test data
select i.created_on, i.image_path, i.cloud_fraction, gu.plant_id, gu.id as generation_id, g.generation as unit_generation from imagery i 
join v_generation_units_usa gu on i.plant_id=gu.plant_id 
join generation g on gu.generation_reporting_id=g.generation_reporting_id
where gu.fuel_type='coal' and gu.capacity>100;