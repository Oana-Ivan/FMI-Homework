--Lab 1
--------------------
set serveroutput on
set verify off
declare
  v_ ;
begin
  dbms_output.put_line('');
end;
/
set verify on
set serveroutput off
------------------------

-- ex 1
begin
    dbms_output.put_line('Invat pl/sql');
end;
/

-- ex 2
declare
  v_oras locations.city%type;
begin
  select city into v_oras
  from locations join departments using (location_id)
  where department_id = 30;
  dbms_output.put_line(v_oras);
end;
/
-- ex 3
declare
  v_media_sal employees.salary%type;
  v_dept number(4);
begin
  select avg(salary) into v_media_sal
  from employees
  where department_id = 50;
  dbms_output.put_line(v_media_sal);
end;
/
-- ex 4
declare
  v_nr_ang number(4);
  dep departments.department_id%type;
begin
  select count(*) into v_nr_ang
  from employees
  where department_id = &dep;
  case 
    when (v_nr_ang <= 10) then dbms_output.put_line('dep mic');
    when (v_nr_ang <= 30) then dbms_output.put_line('dep mediu');
--    when (v_nr_ang > 30) then dbms_output.put_line('dep mare');
    else dbms_output.put_line('dep mare'||dep);
  end case;
end;
/
-- verificare:
--select count(*), department_id
--from employees
--group by department_id;

-- ex 5
create table angajati as select * from employees;

define p_cod_dep = 80;
define p_com = 50

declare
  v_cod_dep departments.department_id%type := &p_cod_dep;
--  p_com number(4);
begin
  update angajati
  set commission_pct = &p_com/100
  where department_id = v_cod_dep;
  
  if sql%rowcount = 0 then 
      dbms_output.put_line('Nicio linie actualizata');
  else dbms_output.put_line(sql%rowcount || ' linii actualizate');
  end if;
  
  dbms_output.put_line('succes');
end;
/
commit;
select * from angajati where --commission_pct is not null order by department_id;
department_id = 80;

-- ex 6
declare
  v_zi varchar2(25) := '&abreviere_zi';  
begin
  case v_zi
    when 'Lu' then dbms_output.put_line('Yac');
    when 'Ma' then dbms_output.put_line('Marti');
    when 'Mi' then dbms_output.put_line('Miercuri');
    when 'Jo' then dbms_output.put_line('Joi');
    when 'Vi' then dbms_output.put_line('Ok-ish');
    when 'Sa' then dbms_output.put_line('Yey');
    else dbms_output.put_line('Ok');
  end case;
end;
/
-- var 2
declare
  v_zi char(2) := upper('&abreviere_zi');  
  v_afisare varchar2(25);
begin
  case
    when v_zi ='LU' then v_afisare := 'Yac';
    when v_zi = 'MA' then v_afisare := 'Marti';
    when v_zi = 'MI' then v_afisare := 'Miercuri';
    when v_zi = 'JO' then v_afisare := 'Joi';
    when v_zi = 'VI' then v_afisare := 'Ok-ish';
    when v_zi = 'SA' then v_afisare := 'Yey';
    when v_zi = 'DU' then v_afisare := 'Ok';
    else v_afisare := 'eroare';
  end case;
  dbms_output.put_line(v_afisare);
end;
/

-- ex 7
alter table angajati
add vechime varchar2(200);
select * from angajati;

declare
  v_vechime number(4);
  v_cod_angajat number(3) := &cod;
  v_aux varchar2(200);
begin
    select round((sysdate - hire_date)/365, 0) into v_vechime
    from employees
    where employee_id = v_cod_angajat;
    
    v_aux := '';
    
    for c in 1..v_vechime loop
        v_aux := v_aux || '#';
    end loop;
    
    update angajati
    set vechime = v_aux
    where employee_id = v_cod_angajat;
    
    dbms_output.put_line('succes');
end;
/
select to_date(to_char(sysdate), 'yyyy')
from dual;

-- ex 8
declare 
  v_n number(3) := &nr;
  v_rezultat number(5);
begin
  v_rezultat := 1;
  for i in 1..v_n loop
    v_rezultat := (v_rezultat * i);
  end loop;
  dbms_output.put_line(v_n || '! = ' || v_rezultat);
end;
/

-- Probleme propuse 
-- ex 1
set verify off
<<bloc>>
declare
  v_cantitate number(3) := 300;
  v_mesaj VARCHAR2(255) := 'Produs 1';
BEGIN
    <<subbloc>>
    DECLARE
      v_cantitate number(3) := 1;
      v_mesaj varchar2(255) := 'Produs 2';
      v_locatie VARCHAR2(50) := 'Europa';
    BEGIN
      v_cantitate := v_cantitate + 1;
      v_locatie := v_locatie || ' de est';
      dbms_output.put_line('Subloc: ' || v_cantitate || '. ' || v_mesaj || ' '|| v_locatie);
    END;
      v_cantitate:= v_cantitate + 1;
      v_mesaj := v_mesaj ||' se afla in stoc';
--      v_locatie := v_locatie || ' de est' ;
      dbms_output.put_line('Bloc: ' || v_cantitate || '. ' || v_mesaj); -- || v_locatie);
end;
/

-- ex 2
declare
  x number(2) := &x;
  y number(2) := &y;
  f number(2);
begin
  if y = 0 then f := x*x;
  else f := x/y + y;
  end if;
  dbms_output.put_line('f = ' || f);
end;
/

-- ex 3
declare
  v_sum_sal number(10);
  v_cod_job jobs.job_id%type; --:= '&cod_job';
begin
  select sum(salary) into v_sum_sal
  from employees
  where job_id = upper('&v_cod_job');
  dbms_output.put_line('sum sal: ' || v_sum_sal);
end;
/
select job_id from employees group by job_id;

-- ex 4
declare
  v_cod_ang employees.employee_id%type := '&cod';
  v_commission_initial employees.commission_pct%type;
  v_commission employees.commission_pct%type;
  v_salariu angajati.salary%type;
begin
  select commission_pct, salary into v_commission_initial, v_salariu
  from angajati
  where employee_id = v_cod_ang;
  
  dbms_output.put_line('Salariu: ' || v_salariu || '. Comision initial: ' || v_commission_initial);
  
  case 
    when v_salariu <= 1000 then v_commission := 0.1 * v_salariu;  
    when v_salariu <= 1500 then v_commission := 0.15 * v_salariu;
    when (v_salariu > 1500 and v_salariu < 15000) then v_commission := 0.2 * v_salariu;
    else v_commission := 0;
  end case;
  
  dbms_output.put_line('Noul comision: ' || v_commission);
  
  if v_commission <> 0 then
      update angajati
      set commission_pct = v_commission
      where employee_id = v_cod_ang;
  end if;
  
  if sql%rowcount = 0 then 
      dbms_output.put_line('Nicio linie actualizata');
  else dbms_output.put_line('succes');
  end if;
end;
/

-- ex 5
create table org_tab (cod_tab integer, text_tab varchar2(200));

declare 
  i number(2);
begin
  i := 1;
  loop
     insert into org_tab (cod_tab, text_tab)
     values (i, 'inregistrarea ' || i);
     i := i + 1;
     exit when i > 70;
  end loop;
end;
/

truncate table org_tab;

declare 
  i number(2);
begin
  i := 1;
  while i <= 70 loop
     insert into org_tab (cod_tab, text_tab)
     values (i, 'inregistrarea ' || i);
     i := i + 1;
  end loop;
end;
/

-- ex 6
declare
  i number(2);
begin
  i := 1;
  while i <= 70 loop
     update org_tab
     set text_tab = 'nr impar'
     where cod_tab = i;
     i := i + 1;
     
     update org_tab
     set text_tab = 'nr par'
     where cod_tab = i;
     i := i + 1;
  end loop;
end;
/

--ex 7
--define v_cmax = '&&nr';
--define v_cmax;
declare
  v_cmax departments.department_id%type;
begin
  select max(department_id) into v_cmax
  from departments;
  
  dbms_output.put_line(v_cmax);
--  define cmax := v_cmax;
end;
/

--ex 8
create table dep as select * from departments;

--define  v_nume := '&nume_dep';

declare
  v_nume dep.department_name%type;
  v_cmax dep.department_id%type;
begin
  select max(department_id) into v_cmax
  from dep;
  
  v_nume := '&nume_dep';
  
  insert into dep (department_id, department_name, location_id)
  values (v_cmax+10, v_nume, null);
end;
/
rollback;
-- ex 9
declare
  v_cmax dep.department_id%type;
begin
  select max(department_id) into v_cmax
  from dep;
  
  update dep
  set location_id = '&noua_loc'
  where department_id = v_cmax;
end;
/

-- ex 10
set serveroutput on
declare
  v_cod_dep dep.department_id%type;
begin
  v_cod_dep := '&dep';
  
  delete from dep
  where department_id = v_cod_dep;
  
  dbms_output.put_line(sql%rowcount || ' linii afectate');
end;
/
-- pentru cod gresit de departament nu da eroare