-- SUBPROGRAME

-- stocate(create cu create) sau locale(in cadrul unui bloc sau alt subprogram)

Sintaxa simplificat? pentru crearea unei PROCEDURI este urm?toarea:
      [CREATE [OR REPLACE] ] PROCEDURE nume_procedura [ (lista_parametri) ]
      {IS | AS}
          [declaratii locale]
      BEGIN
          partea executabila
          [EXCEPTION
          partea de tratare a exceptiilor]
      end [NUME_PROCEDURA];

Sintaxa simplificata pentru crearea unei FUNCTII este urmatoarea:
      [create [or replace] ] function nume_functie
          [ (lista_parametri) ] -- doar parametri de tip IN
          RETURN tip_de_date
      {IS | AS}
          [declaratii locale]
      BEGIN
          partea executabila
          [EXCEPTION
          partea de tratare a exceptiilor]
        END [NUME_FUNCTIE];
lista parametrilor: param separati prin virgula de forma:
nume_parametru mod_parametru(poate fi in(default?), in out, out) tip_parametru

-- Proceduri locale
-- ex 1
set serveroutput on
set verify off
declare
      procedure ex1 
          (department_id dep.department_id%type, 
           department_name dep.department_name%type,
           manager_id dep.manager_id%type, 
           location_id dep.location_id%type) is
      begin
        insert into dep
        values(department_id, department_name, manager_id, location_id);
      end ex1;
begin
    ex1(15, 'Biscuiti', 101, 2500); 
    dbms_output.put_line('add biscuiti');
end;
/

-- ex 2
declare
      procedure ex2 
          (p_rezultat in out angajati.last_name%type, 
           p_comision out angajati.commission_pct%type := null,
           p_cod angajati.employee_id%type := null) is
      begin
        if (p_comision is not null) then  select last_name into p_rezultat
                                          from angajati
                                          where commission_pct = p_comision 
                                                 and salary = (select max(salary)
                                                               from angajati
                                                               where commission_pct = p_comision);
        else (select last_name into p_rezultat from angajati where employee_id = p_cod);
      end if;
      end ex2;
begin
    ex2('', 0.13, 128); 
    dbms_output.put_line('succes');
end;
/
DECLARE
      nume employees.last_name%type;
      
      procedure p2l4_pnu (p_rezultat in out employees.last_name% type,
                          p_comision IN employees.commission_pct %TYPE:=NULL,
                          p_cod IN employees.employee_id %TYPE:=NULL)
      IS
      BEGIN
      if (p_comision is not null) then
              SELECT last_name INTO p_rezultat
              FROM employees
              WHERE commission_pct= p_comision
                    AND salary = (SELECT MAX(salary)
                                  FROM employees
                                  WHERE commission_pct = p_comision);
              DBMS_OUTPUT.PUT_LINE('Numele salariatului care are comisionul '||p_comision||' este '||p_rezultat);
      ELSE
              SELECT last_name INTO p_rezultat
              FROM employees
              where employee_id = p_cod;
              DBMS_OUTPUT.PUT_LINE('numele salariatului avand codul '||p_cod|| ' este '||p_rezultat);
      END IF;
      END;
begin -- partea executabil a blocului
      p2l4_pnu (nume, null, 101);      
--      p2l4_pnu (nume, null, 205);
END;
/
-- Proceduri stocate
-- ex 3
create or replace procedure ex3 is
begin
  dbms_output.put_line('Vine Craciunuuuuul');
  dbms_output.put('Suntem in data de ');
  dbms_output.put_line(to_char(sysdate, 'dd-mon-yyyy hh24:mi:ss'));
  dbms_output.put('Ieri am fost pe data de  ');
  dbms_output.put_line(to_char(sysdate-1, 'dd-mon-yyyy'));
end ex3;
/
declare
begin
  ex3();
end;
/

-- ex 4
drop procedure ex3;

create or replace procedure ex4 (p_nume in varchar2)
is
begin
  dbms_output.put_line(p_nume || ' s-a apucat taaaaarziuuuu de invatat pentru partial');
end ex4;
/
declare
begin
  ex4('Oana');--(user);
end;
/
-- ex 5, a
create table jobs_oiv as (select * from jobs);
alter table jobs_oiv
add constraint pk_jobs_oiv primary key(job_id);
-- b
create or replace procedure add_job (p_id in varchar2, p_title in varchar2) is
begin
  insert into jobs_oiv
  values(p_id, p_title, 1000, 3000);
end add_job;
/

begin
  add_job('lala', 'Lalalalala');
end;
/

-- ex 6
create or replace procedure upd_job (p_cod in varchar2, p_denumire in varchar2) is
begin
  update jobs_oiv
  set job_title = p_denumire
  where job_id = p_cod;
  
  if sql%notfound then raise_application_error(-20202, 'Nicio actualizare');
  end if;
  
end;
/
begin
  upd_job('lala', ' blablabla');
  upd_job('lala1', ' blablabla');
end;
/

EXECUTE UPD_JOB('lala', 'Data Administrator');
--execute upd_job(‘it_web’, ‘web master’);

-- ex 7, a
create or replace procedure del_job (cod in varchar2) is
begin
    delete from jobs_oiv
    where job_id = cod;
     if sql%notfound then raise_application_error(-20202, 'Nicio stergere');
  end if;
end;
/
begin
  del_job('lala');
end;
/

-- ex 8
create or replace procedure ex8 (sal out angajati.salary%type) is
begin
    select avg(salary) into sal
    from angajati;
end;
/
set serveroutput on
declare
  s angajati.salary%type;
begin
  ex8(s);
  dbms_output.put_line(to_char(s));
end;
/

-- ex 9, a
create or replace procedure ex9 (sal in out angajati.salary%type) is
begin
    if sal <= 3000 then sal := sal * 1.2;
    elsif  sal <= 7000 then  sal := sal * 1.15;
    elsif sal > 7000 then sal  := sal * 1.1;
    else sal := 1000;
    end if;
end;
/
declare
  s angajati.salary%type := &val;
begin
  ex9(s);
  dbms_output.put_line(to_char(s));
end;
/

-- FUNCTII LOCALE
-- ex 10
create or replace procedure ex10_p (cod in dep.department_id%type) as
-- declaratii locale ale procedurii 
    function nr_sal (cod in dep.department_id%type) return number
    is
        v_nr number(3);
    begin
        select count(*) into v_nr
        from employees
        where department_id = cod;
        
        return v_nr;
    end nr_sal;
    
    function sum_sal (cod in dep.department_id%type) return number
    is
        v_nr number(3);
    begin
        select sum(salary) into v_nr
        from employees
        where department_id = cod;
        
        return v_nr;
    end sum_sal;
    
    function nr_man (cod in dep.department_id%type) return number
    is
        v_nr number(3);
    begin
        select count(employee_id) into v_nr
        from employees
        where department_id = cod and employee_id in (select manager_id from employees);
        
        return v_nr;
    end nr_man;
-- partea de excutare aprocedurii
begin 
    dbms_output.put_line(nr_sal(cod));
    dbms_output.put_line(sum_sal(cod));
    dbms_output.put_line(nr_man(cod));
end ex10_p;
/

begin
  ex10_p(30);
end;
/
-- ex 11
declare
  m1 number(10, 2);
  function medie (cod dep.department_id%type) return number
  is
    m number(10, 2);
  begin
    select avg(salary) into m
    from employees
    where department_id = cod;
    return m;
  end;
  
  function medie (cod dep.department_id%type, j jobs.job_id%type) return number
  is
    m number(10, 2);
  begin
    select avg(salary) into m
    from employees
    where department_id = cod and job_id = j;
    return m;
  end;
  
begin
  m1 := medie(30);
end;
/
 DECLARE
      medie1 NUMBER(10,2);
      medie2 number(10,2);
      
      FUNCTION medie (v_dept employees.department_id%TYPE) RETURN NUMBER IS
        rezultat NUMBER(10,2);
      BEGIN
        SELECT AVG(salary) INTO rezultat
        from employees
        where department_id = v_dept; 
        
        RETURN rezultat;
      end;
      
      FUNCTION medie (v_dept employees.department_id%TYPE, v_job employees.job_id %TYPE)
      RETURN NUMBER IS
        rezultat NUMBER(10,2);
      BEGIN
        SELECT AVG(salary) INTO rezultat
        FROM employees
        WHERE department_id = v_dept AND job_id = v_job;
        RETURN rezultat;
      END;
BEGIN
      medie1:=medie(80);
      DBMS_OUTPUT.PUT_LINE('Media salariilor din departamentul 80 este ' || medie1);
      medie2 := medie(80, 'SA_REP');
      DBMS_OUTPUT.PUT_LINE('Media salariilor reprezentantilor de vanzari din
      departamentul 80 este ' || medie2);
end;
/

-- FUNCTII STOCATE
-- ex 12
create or replace function ex12 (dep emp.department_id%type) return number is
nr number(4);
begin
  select count(*) into nr
  from employees
  where department_id = dep and to_char(hire_date, 'yyyy') = '1995';
  return nr;
end ex12;
/
-- 1, variabila de legatura
variable nr number
execute :nr := ex12(50);
print nr;
-- 2. call
--variable nr2 number
--call ex12(50) into :nr2;
--print nr2;
-- 3, comanda select
select ex12(50)
from dual;
-- 4, bloc pl/sql
declare 
  nr number(3);
begin
  nr := ex12(50);
  dbms_output.put_line(nr);
end;
/
-- ex 13
create or replace function valid_deptid (dep dep.department_id%type) return boolean is
  exista varchar(1);
begin
  select 'x' into exista
  from departments
  where department_id = dep;
  return (true);
  
  exception
    when no_data_found then return (false);
end;
/
begin
    if valid_deptid(5000) then dbms_output.put_line('yep');
    else dbms_output.put_line('nop');
    end if;
end;
/
-- b
--create or replace procedure add_emp 
--     (p_lname employees.last_name%TYPE,
--      p_fname employees.first_name%TYPE,
--      p_email employees.email%TYPE,
--      p_job employees.job_id%TYPE DEFAULT 'SA_REP',
--      p_mgr employees.manager_id%TYPE DEFAULT 145,
--      p_sal employees.salary%TYPE DEFAULT 1000,
--      p_comm employees.commission_pct%TYPE DEFAULT 0,
--      p_deptid employees.department_id%TYPE DEFAULT 30)
-- is
--begin
--  insert into angajati
--  values(980, p_lname, p_fname, p_email, p_job, p_sal, p_comm, p_mgr, p_deptid, '#');
--end;
--/

-- ex 14
-- nr permutari = n factorial
create or replace function ex14 (n number) return number
is
rezultat number(4);
begin
   if n = 0 then rezultat := 1;
   else rezultat := n * ex14(n-1);
   end if;
   return rezultat;
end;
/
select ex14(5)
from dual;

-- ex 15
create or replace function ex15 return number is
medie number(4);
begin
  select avg(salary) into medie
  from employees;
  return medie;
end;
/
select last_name || ' ' || first_name "nume_complet", job_id, salary
from employees
where salary >= ex15; 