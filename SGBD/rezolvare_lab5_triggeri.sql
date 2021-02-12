-- Triggeri

--CREATE [OR REPLACE] TRIGGER [schema.]nume_trigger
--{BEFORE | AFTER}
--[INSTEAD OF]
--{DELETE | INSERT | UPDATE [OF coloana[, coloana ...] ] }
--[OR {DELETE | INSERT | UPDATE [OF coloana[, coloana ...] ] ...}
--ON [schema.]nume_tabel
--[REFERENCING {OLD [AS] vechi NEW [AS] nou
--| NEW [AS] nou OLD [AS] vechi } ]
--[FOR EACH ROW]
--[WHEN (condi?ie) ]
--CORP_TRIGGER;
--
--Informa?ii despre triggeri:
--USER_TRIGGERS, USER_TRIGGER_COL, ALL_TRIGGERS, DBA_TRIGGERS.
--
--ALTER TRIGGER nume_trigger ENABLE;
--ALTER TRIGGER nume_trigger DISABLE;
--ALTER TRIGGER nume_trigger COMPILE;
--ALTER TRIGGER NUME_TRIGGER RENAME TO NUME_NOU;
--
--ALTER TABLE nume_tabel
--DISABLE ALL TRIGGERS;
--
--ALTER TABLE nume_tabel
--ENABLE ALL TRIGGERS;
--
--Eliminarea unui declan?ator:
--DROP TRIGGER NUME_TRIGGER;

-- EXERCITII
-- 1
--S? se creeze un trigger care asigur? ca inserarea de angaja?i în tabelul EMP se poate realiza
--NUMAI ÎN ZILELE LUCR?TOARE, ÎNTRE ORELE 8-18.
CREATE OR REPLACE TRIGGER WORK_HOURS BEFORE INSERT ON employees
BEGIN
  IF (TO_CHAR(SYSDATE, 'd') IN ('1', '7')) OR 
      (TO_CHAR(SYSDATE, 'hh24') NOT BETWEEN '08' AND '18') 
      then
      raise_application_error(-20500, 'Nu e zi de lucru, teapa');    
  end if;
END;
/
drop trigger WORK_HOURS;
select to_char(sysdate, 'd')
FROM DUAL;
INSERT INTO EMPLOYEES(EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID )
values(900, 'Nume900', 'email900', sysdate, 'IT_PROG');

-- 3
CREATE OR REPLACE TRIGGER LAB5_EX3 
BEFORE INSERT OR UPDATE OF SALARY ON EMPLOYEES
for each row
BEGIN
  IF (UPPER(:NEW.JOB_ID) <> 'AD_PRES') AND (UPPER(:NEW.JOB_ID) <> 'AD_VP') AND (:NEW.SALARY > 15000) THEN
    RAISE_APPLICATION_ERROR(-20500, ' numai salaria?ii având codul job-ului AD_PRES sau AD_VP pot câ?tiga mai mult de 15000.');
  end if;
END;
/

UPDATE EMPLOYEES
SET SALARY = 15500
where employee_id = 103;

-- 4
CREATE OR REPLACE TRIGGER LAB5_EX4
BEFORE UPDATE OF SALARY ON EMPLOYEES
FOR EACH ROW
BEGIN
  IF :NEW.SALARY < :OLD.SALARY THEN
    raise_application_error(-20501, ' Nu mai taiati salariile!' );
  end if;
END;
/

UPDATE EMPLOYEES
SET SALARY = 15
WHERE EMPLOYEE_ID = 103;

-- 5 - pas, cerinta incompleta

-- 6
--CREATE OR REPLACE TRIGGER LAB5_EX6 
--DECLARE
--  V_MIN EMPLOYEES.SALARY%TYPE;
--  V_MAX EMPLOYEES.SALARY%TYPE;
--BEGIN
--  SELECT MIN(SALARY), MAX(SALARY) into v_min, v_max
--  FROM EMPLOYEES;
--  
--END;
--/

-- 7
CREATE TABLE EMP_COPY AS (SELECT * FROM EMPLOYEES);
create table emp_oiv as (select * from employees);

CREATE OR REPLACE TRIGGER LAB5_EX7_copie_tabel
BEFORE INSERT OR UPDATE OF SALARY, JOB_ID ON EMP_oiv
FOR EACH ROW
when (new.job_id <> 'AD_PRES')
declare
  V_MIN EMP.SALARY%TYPE;
  v_max emp.salary%type;
BEGIN
  SELECT MIN(SALARY), MAX(SALARY) INTO V_MIN, V_MAX
  FROM EMP_copy
  WHERE JOB_ID = :NEW.JOB_ID;
  
  IF :new.SALARY > V_MAX OR :new.SALARY < V_MIN THEN
    raise_application_error(-20450, 'Salariul nu este intre limitele job_ului ');
  end if;
END;
/
SELECT *-- MIN(SALARY)
FROM EMP
WHERE JOB_ID = 'IT_PROG';

UPDATE EMP
SET SALARY = 300
where employee_id = 104;

-- 8
-- a
CREATE TABLE DEPT_EX8 AS SELECT * FROM DEPARTMENTS;
ALTER TABLE DEPT_EX8 ADD (TOTAL_SAL NUMBER(11, 2));

UPDATE dept_ex8
set total_sal = (select sum(salary) 
                 from employees
                 where employees.department_id = dept_ex8.department_id);
                 
-- b
create or replace procedure add_total_sal(v_dep_id in dept_ex8.department_id%type, 
                                          v_sal in dept_ex8.total_sal%type) as
begin
    update dept_ex8
    set total_sal = nvl(total_sal, 0) + v_sal
    where department_id = v_dep_id;
end add_total_sal;
/

 create or replace trigger ex8 
 after insert or delete or update of salary on emp_oiv
-- update of department_id ??
 for each row
 begin
    if deleting then
        add_total_sal(:old.department_id, (-1) * :old.salary);
    elsif updating then
        add_total_sal(:new.department_id, :new.salary - :old.salary);
    else
        add_total_sal(:new.department_id, :new.salary);
     end if;
 end;
 /

create or replace procedure CRESTE_TOTAL_PNU
        (V_COD_DEP in DEPT_EX8.DEPARTMENT_ID%type,
        V_SAL in DEPT_EX8.TOTAL_SAL%type) as
begin
      update DEPT_EX8
      set TOTAL_SAL = NVL(TOTAL_SAL, 0) + V_SAL
      where DEPARTMENT_ID = V_COD_DEP;
end CRESTE_TOTAL_PNU;
/
CREATE OR REPLACE TRIGGER calcul_total_pnu
AFTER INSERT OR DELETE OR UPDATE OF salary ON emp_oiv
FOR EACH ROW
BEGIN
    IF DELETING THEN
        creste_total_pnu (:OLD.department_id, -1 * :OLD.salary);
    ELSIF UPDATING THEN
        creste_total_pnu (:NEW.department_id, :NEW.salary - :OLD.salary);
    ELSE /* inserting */
        Creste_total_pnu (:NEW.department_id, :NEW.salary);
    END IF;
END;
/
-- 9
create table new_emp as select * from employees;
create table new_dept as select * from departments;
CREATE TABLE new_dept_oiv AS
    SELECT d.department_id, d.department_name, d.location_id, SUM(e.salary) total_dept_sal
    FROM employees e, departments d
    WHERE e.department_id = d.department_id
    GROUP BY d.department_id, d.department_name, d.location_id;

create or replace view lab5_ex9 as 
  (select employee_id, last_name, salary, department_id, email, job_id, department_name, location_id
   from employees join departments using (department_id)
  );

create or replace trigger ex9_lala 
before insert on employees
--instead of insert on lab5_ex9
--for each row
begin
    DBMS_OUTPUT.PUT('lala');
--    insert into new_emp(employee_id, last_name, email, hire_date, salary, department_id, job_id)
--    values(:new.employee_id, :new.last_name, :new.email, sysdate, :new.salary, :new.department_id, :new.job_id);
    
--    update new_dept_oiv
--    set total_dept_sal = total_dept_sal + :new.salary
--    where department_id = :new.department_id;
end;
/
drop trigger ex9_lala;

create or replace trigger ex9
instead of insert on lab5_ex9
for each row
begin
--    insert into new_emp(employee_id, last_name, email, hire_date, salary, department_id, job_id)
--    values(:new.employee_id, :new.last_name, :new.email, sysdate, :new.salary, :new.department_id, :new.job_id);
    INSERT INTO new_emp
    VALUES(:NEW.employee_id, :NEW.last_name, :NEW.salary, :NEW.department_id, :NEW.email, :NEW.job_id, SYSDATE);

--    update new_dept_oiv
--    set total_dept_sal = total_dept_sal + :new.salary
--    where department_id = :new.department_id;
end;
/

----------------------------------
-- ex 9, attempt 2
CREATE TABLE new_emp2 AS
      SELECT employee_id, last_name, salary, department_id, email, job_id, hire_date
      FROM employees;

CREATE TABLE new_dept2 AS
      SELECT d.department_id, d.department_name, d.location_id, SUM(e.salary) total_dept_sal
      FROM employees e, departments d
      WHERE e.department_id = d.department_id
      GROUP BY d.department_id, d.department_name, d.location_id;

CREATE VIEW view_emp_pnu AS
      SELECT e.employee_id, e.last_name, e.salary, e.department_id, e.email,
             e.job_id, d.department_name, d.location_id
      FROM employees e, departments d
      WHERE e.department_id = d.department_id;

create or replace trigger ex9_view 
instead of insert or delete or update on view_emp_pnu
for each row
begin
    if inserting then
          insert into new_emp2
          values(:new.employee_id, :new.last_name, :new.salary, :new.department_id, :new.email,
                   :new.job_id, sysdate);
          update new_dept2
          set total_dept_sal = total_dept_sal + :new.salary
          where department_id = :new.department_id; 
    elsif deleting then
          delete from new_emp2
          where employee_id = :old.employee_id;
          
          update new_dept2
          set total_dept_sal = total_dept_sal - :old.salary
          where department_id = :old.department_id; 
    else -- updating
          if updating('salary') then
              update new_emp2
              set salary = :new.salary
              where employee_id = :new.employee_id;
          elsif updating('department_id') then
              update new_emp2
              set department_id = :new.department_id
              where employee_id = :old.employee_id;
          end if;
    
          update new_dept2
          set total_dept_sal = total_dept_sal - :old.salary
          where department_id = :old.department_id;
          
          update new_dept2
          set total_dept_sal = total_dept_sal + :new.salary
          where department_id = :new.department_id;
    end if;
end;
/
delete from view_emp_pnu
where employee_id = 100;

insert into view_emp_pnu
values(9, 'Lalalalala', 12000, 60, 'lalala@lala.com', 'SA_REP', 'IT', 1400);

update view_emp_pnu
set salary = 3
where employee_id = 101;

-- 10
create or replace trigger max50_ang 
before insert or update of department_id on new_emp2
for each row
declare
    v_nr_ang number;
begin
    select count(*) into v_nr_ang
    from new_emp2
    where department_id = :new.department_id;
    
    dbms_output.put_line('Count: ' || v_nr_ang);
    
    if v_nr_ang + 1 > 47 then
        raise_application_error(-20100, 'Prea multi angajati in departamentul ' || :new.department_id || '. Maximul = 50');
    end if;
end;
/
drop trigger max50_ang;
set serveroutput on
select count(*), department_id
from new_emp2
group by department_id;

insert into new_emp2
values(900, 'Lalalalala', 12000, 50, 'lalala@lala.com', 'SA_REP', sysdate);
rollback;
insert into new_emp2
(select employee_id + 100, last_name, salary, department_id, email, job_id, hire_date from employees);

create table dept_copy as select * from departments;
---- Rezolvarea fancy:
create or replace package p_max50ang as
     type vector_coduri_dep is table of dept_copy.department_id%type index by binary_integer;
     
     v_coduri_dep vector_coduri_dep;
     v_nr_intrari binary_integer := 0;
end p_max50ang;
/

-- salvam intr-un vector departamentele in care inseram angajati
create or replace trigger tb_max50ang
    before insert on new_emp2
    for each row
begin
    p_max50ang.v_nr_intrari := p_max50ang.v_nr_intrari + 1;
    p_max50ang.v_coduri_dep(p_max50ang.v_nr_intrari) := :new.department_id;
end tb_max50ang;
/

-- 
create or replace trigger tb_all_max50ang
    before insert on new_emp2
declare
    v_max_ang constant number := 50;
    v_nr_curent number;
    v_cod_dep dept_oiv.department_id%type;
begin
    for i in 1..p_max50ang.v_nr_intrari loop
        v_cod_dep := p_max50ang.v_coduri_dep(i);
        
        select count(*) into v_nr_curent
        from new_emp2
        where department_id = v_cod_dep;
        
        if v_nr_curent > v_max_ang then 
            raise_application_error(-20123, 'Prea multi angajati in dep ' || v_cod_dep);
        end if;
    end loop;
    
    p_max50ang.v_nr_intrari := 0;
end tb_all_max50ang;
/

-- ex 11
-- a
--create table emp_copy as select * from employees;
--drop trigger ex10;
create or replace trigger ex11
before delete or update of department_id on dept_copy
for each row

begin
    if deleting then 
        delete from emp_copy
        where department_id = :old.department_id;
    end if;
    
    if updating then
        update 
    end if;
    
end;
/
-- ex 12
create or replace trigger ex12
before delete on emp_copy
begin
  if user = 'OANAIVAN13' then
      raise_application_error(-20102, 'User-ul nu poate efectua stergeri in tabelul emp_copy');
  end if;
end;
/
select user
from dual;

delete from emp_copy
where employee_id = 105;
rollback;
alter trigger ex12 disable;
alter trigger ex12 enable;
drop trigger ex12;

-- 13
create table log_oiv (user_id VARCHAR2(30),
                      nume_bd VARCHAR2(50),
                      eveniment_sis VARCHAR2(20),
                      nume_obj VARCHAR2(30),
                      data DATE);
create or replace trigger operatii_ldd 
after create or drop or alter on schema
begin
    insert into log_oiv
    values(user, sys.database_name, sys.sysevent, sys.dictionary_obj_name, sysdate);
end;
/

create view exemplu as select * from jobs;
drop view exemplu;
drop trigger operatii_ldd;
select * from log_oiv;


--------------------------------------------------------------------------------

-- Runda 2:
create table emp2 as select * from employees;
create table dep2 as select * from departments;
set serveroutput on

-- ex 1
create or replace trigger ore_lucratoare
before insert on emp2
begin
    if ((to_char(sysdate, 'd') not in (2, 3, 4, 5, 6)) or (to_char(sysdate, 'HH24') not between '8' and '18') ) then
      raise_application_error(-20100, 'Nu se pot insera angajati in afara programului');
    end if;
end;
/
select to_char(sysdate, 'HH24') from dual;
insert into emp2 select * from employees;
rollback;

-- ex 2
create or replace trigger ore_lucratoare
before insert or delete or update on emp2
begin
    if ((to_char(sysdate, 'd') not in (2, 3, 4, 5, 6)) or (to_char(sysdate, 'HH24') not between '8' and '18') ) then
      if (inserting) then
          raise_application_error(-20100, 'Nu se pot insera angajati in afara programului');
      end if;
      
      if (deleting) then
          raise_application_error(-20100, 'Nu se pot sterge angajati in afara programului');
      end if;
      
      if (updating('salary')) then
          raise_application_error(-20100, 'Nu se poate modifica salariul in afara programului');
      end if;
      
      if (updating) then
          raise_application_error(-20100, 'Nu se pot actualiza informatii despre salariati in afara programului');
      end if;
      
    end if;
end ore_lucratoare;
/
insert into emp2 select * from employees;
update emp2
set hire_date = sysdate
where employee_id = 100;
update emp2
set salary = 90
where employee_id = 100;
delete from emp2
where employee_id = 100;

alter trigger ore_lucratoare disable;

-- ex 3
create or replace trigger r2ex3 
before insert or update of salary on emp2
for each row
when (lower(new.job_id) not in ('ad_pres', 'ad_vp'))
declare
    lim_sal constant number := 15000;
begin
    if (:new.salary > lim_sal) then
        raise_application_error(-20100, 'Salariul nu poate depasi ' || lim_sal || 
                                ' pentru alt job in afara de ad_pres sau ad_vp');
    end if;
end r2ex3;
/
select *
from employees
where lower(job_id) in ('ad_pres', 'ad_vp');

update emp2 
set salary = salary + 15000;
--where employee_id = 100;

INSERT INTO EMP2(EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, salary )
values(900, 'Nume900', 'email900', sysdate, 'IT_PROG', 15001);
rollback;

-- ex 4
create or replace trigger sal_min 
before update of salary on emp2
for each row
--when (new.salary < old.salary)
begin
    if (:new.salary < :old.salary) then
    raise_application_error(-20100, 'Scaderile de salariu nu sunt acceptate');
    end if;
end;
/
update emp2
set salary = 1;
--where employee_id = 100;

-- varianta cu procedura care nu merge :D
create or replace procedure p_sal_min is
begin
    raise_application_error(-20100, 'Scaderile de salariu nu sunt acceptate');
end;
/
create or replace trigger sal_min_p 
before update of salary on emp2
for each row
when (new.salary < old.salary)
call p_sal_min;

-- ex 5 - skip cerinta incompleta

-- ex 6
create or replace trigger limite_sal
before update of min_salary, max_salary on jobs_oiv
for each row
declare
    cursor c_salarii is (select salary
                         from emp2
                         where lower(job_id) = lower(:new.job_id));
    sal_curent employees.salary%type;
begin
    open c_salarii;
    fetch c_salarii into sal_curent;
    while (c_salarii%found) loop
        if (sal_curent not between :new.min_salary and :new.max_salary) then
            raise_application_error(-20100, 'Limitele nu corespund cu salariile deja respective');
        end if;
        fetch c_salarii into sal_curent;
    end loop;
    
    close c_salarii;
end limite_sal;
/
update jobs_oiv
set max_salary = 100
where lower(job_id) = 'it_prog';

-- ex 7
create or replace trigger verifica_salariu 
before insert or update of salary, job_id on emp2
for each row
when (lower(new.job_id) <> 'ad_pres')
declare 
    min_sal jobs.min_salary%type;
    max_sal jobs.max_salary%type;
begin
    select min_salary, max_salary into min_sal, max_sal
    from jobs_oiv
    where job_id = :new.job_id;
    
    if (:new.salary not between min_sal and max_sal) then
        raise_application_error(-20100, 'Salariul angajatului nu este in limitele impuse de job');
    end if;
end verifica_salariu;
/
UPDATE emp2
SET salary = 3500
WHERE last_name = 'Stiles';
-----------------------
-- rezolvarea fancy:
create or replace package vsp is-- verifica_salariu_p is
    type limita_sal is record (job_i emp2.job_id%type,
                               min_sal emp2.salary%type,
                               max_sal emp2.salary%type);
    type limite_sal is table of limita_sal index by binary_integer;
    lim_sal limite_sal;
    nr_joburi binary_integer := 0;
end vsp;
/

create or replace trigger verifica_salariul1 
before insert or update of salary, job_id on emp2
declare 
    cursor joburi is (select job_id from jobs);
    id_job_curent jobs.job_id%type;
begin
    open joburi;
    fetch joburi into id_job_curent; 
    
    while (joburi%found) loop
        vsp.nr_joburi := vsp.nr_joburi + 1;
        
        vsp.lim_sal(vsp.nr_joburi).job_i := id_job_curent;
        
        select min(salary), max(salary) 
        into vsp.lim_sal(vsp.nr_joburi).min_sal, vsp.lim_sal(vsp.nr_joburi).max_sal
        from emp2;
        
        fetch joburi into id_job_curent; 
    end loop;
    close joburi;
    
end verifica_salariul1;
/

create or replace trigger verifica_salariul2 
before insert or update of salary, job_id on emp2
for each row
when (lower(new.job_id) <> 'ad_pres')
declare 
    min_sal emp2.salary%type;
    max_sal emp2.salary%type;
begin
    for i in 1..vsp.nr_joburi loop
        if vsp.lim_sal(i).job_i = :new.job_id then
            min_sal := vsp.lim_sal(i).min_sal;
            max_sal := vsp.lim_sal(i).max_sal;
        end if;
    end loop;
    
    if (:new.salary not between min_sal and max_sal) then
        raise_application_error(-20100, 'Salariul angajatului nu este in limitele impuse de job');
    end if;
    vsp.nr_joburi := 0;
end verifica_salariul2;
/
UPDATE emp2
SET salary = 10000;
rollback;
alter trigger sal_min disable;

-- ex 8, dep2
-- a
alter table dep2 add (total_sal number(8, 2));--emp2.salary%type);
update dep2
set total_sal = (select sum(salary) from emp2 where emp2.department_id = dep2.department_id);

-- b
create or replace trigger update_total_sal
after insert or delete or update of salary, department_id on emp2
for each row
begin
    if (inserting) then
        update dep2 
        set total_sal = total_sal + :new.salary
        where department_id = :new.department_id;
    elsif (updating('salary')) then
        update dep2 
        set total_sal = total_sal - :old.salary + :new.salary
        where department_id = :new.department_id;
    elsif (updating('department_id')) then
        update dep2 
        set total_sal = total_sal + :new.salary
        where department_id = :new.department_id;
        
        update dep2 
        set total_sal = total_sal - :old.salary
        where department_id = :old.department_id;
    elsif (deleting) then
        update dep2 
        set total_sal = total_sal - :old.salary
        where department_id = :old.department_id;
    end if;
end update_total_sal;
/
select * from emp2;

update emp2
set department_id = 60
where employee_id = 100;

update emp2
set salary = 60
where employee_id = 101;

delete emp2
where employee_id = 101;

insert into emp2 select * from employees;

rollback;

-- ex 9
create table new_emp_r2 as select * from employees;
create table new_dep_r2 as select * from departments;

create or replace view view_emp_r2 as
(select employee_id, last_name, salary, e.department_id, email, job_id, department_name, location_id
from new_emp_r2 e, dep2 d
where e.department_id = d.department_id);

create or replace trigger instead_r2
instead of insert or delete or update on view_emp_r2
for each row
begin
    if (inserting) then 
        insert into new_emp_r2(employee_id, last_name, salary, department_id, email, job_id, hire_date)
        values(:new.employee_id, :new.last_name, :new.salary, :new.department_id, :new.email, :new.job_id, sysdate);
        
        update dep2
        set total_sal = total_sal + :new.salary
        where department_id = :new.department_id;
        
    elsif (updating('salary')) then
        update new_emp_r2
        set salary = :new.salary
        where employee_id = :new.employee_id;
        
        update dep2
        set total_sal = total_sal - :old.salary + :new.salary
        where department_id = :new.department_id;
        
    elsif (updating('department_id')) then
        update new_emp_r2
        set department_id = :new.department_id
        where employee_id = :new.employee_id;
        
        update dep2
        set total_sal = total_sal - :old.salary
        where department_id = :old.department_id;    
        
        update dep2
        set total_sal = total_sal + :new.salary
        where department_id = :new.department_id;
        
    elsif (deleting) then
        delete new_emp_r2
        where employee_id = :old.employee_id;
        
        update dep2
        set total_sal = total_sal - :old.salary
        where department_id = :old.department_id;
    end if;
      
end;
/
rollback;
insert into view_emp_r2
values(5, 'Nume5', 1200, 60, 'email5', 'IT_PROG', 'IT', 1400);
--employee_id, last_name, salary, e.department_id, email, job_id, department_name, d.location_id, total_sal
insert into view_emp_r2
(select employee_id, last_name, salary, e.department_id, email, job_id, department_name, location_id
from new_emp_r2 e, dep2 d
where e.department_id = d.department_id);
