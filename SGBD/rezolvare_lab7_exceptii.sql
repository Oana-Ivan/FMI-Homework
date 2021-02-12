-- Lab 7 - Exceptii


declare
    
begin
    
exception
    
end;
/

-- ex 1
--  Crea i tabelul erori_pnu având dou coloane: cod_eroare de tip NUMBER i mesaj_eroare de tip
--  VARCHAR2(100). S se scrie un bloc PL/SQL care s determine i s afi eze salariatul angajat cel
--  mai recent într-un departament al c rui cod este introdus de c tre utilizator. Pentru orice eroare
--  ap rut , vor fi inserate codul i mesajul erorii în tabelul erori_pnu.

create table erori (cod_eroare number, mesaj_eroare varchar2(100));

--select max(hire_date) from employees;
--select hire_date from employees order by hire_date;
set serveroutput on
-- Var 1
declare 
  dept departments.department_id%type := '&cod_dep';
  emp employees.employee_id%type;
  
  eroare_cod number;
  eroare_mesaj varchar2(100);
begin
    select employee_id into emp
    from employees
    where department_id = dept and hire_date = (select max(hire_date) from employees); -- where department_id = dept);
    
    dbms_output.put_line('Salariatul avand codul ' || emp || ' este cel mai recent angajat in departamentul ' 
                  || dept);
exception
    when others then
        eroare_cod := sqlcode;
        eroare_mesaj := substr(sqlerrm, 1, 100);
        insert into erori
        values(eroare_cod, eroare_mesaj);
end;
/

-- Var 2
declare 
  dept departments.department_id%type := '&cod_dep';
  emp employees.employee_id%type;
  nr_ang number;
  
  eroare_cod number;
  eroare_mesaj varchar2(100);
  exp exception;
begin
    select count(employee_id) into nr_ang
    from employees;
    where department_id = dept and hire_date = (select max(hire_date) from employees); -- where department_id = dept);
    
    if nr_ang <> 1 then
        raise exp;
    end if;
    
    select employee_id into nr_ang
    from employees;
    where department_id = dept and hire_date = (select max(hire_date) from employees); -- where department_id = dept);
    
    dbms_output.put_line('Salariatul avand codul ' || emp || ' este cel mai recent angajat in departamentul ' 
                  || dept);
exception
    when exp then
        eroare_cod := -20100;
        eroare_mesaj := 'prea multi angajati';
        insert into erori
        values(eroare_cod, eroare_mesaj);
    when others then
        eroare_cod := sqlcode;
        eroare_mesaj := substr(sqlerrm, 1, 100);
        insert into erori
        values(eroare_cod, eroare_mesaj);
end;
/

-- Ex 2
create table mesaj (rezultate varchar2(50));

declare
    loc departments.location_id%type := &loc;
    dep departments.department_name%type;
    nr number;    
    ex_0 exception;
    ex_1 exception;
    ex_many exception;
begin
    select count(department_name) into nr
    from (select department_name, location_id 
          from departments d
          where (select count(*) from employees where department_id = d.department_id) <> 0)
    where location_id = loc;
    
    if nr = 0 then
        raise ex_0;
    elsif nr = 1 then
        raise ex_1;
    else -- many
        raise ex_many;
    end if;
    
exception
    when ex_0 then
        insert into mesaj
        values('Niciun departament');
    when ex_1 then
        insert into mesaj
        values('Un departament');
    when ex_many then
        insert into mesaj
        values('Mai multe departamente');
end;
/

select department_id, location_id from departments order by location_id;

-- Ex 3
delete from departments where department_id = 50;

declare
    dep departments.department_id%type := &dept;
    exista_angajati exception;
    pragma exception_init(exista_angajati, -2292);
begin
    delete from departments where department_id = dep;
exception
    when exista_angajati then
        dbms_output.put_line('Exista angajati in departamentul ' || dep);
end;
/

-- Ex 4

declare
    val number := &nr;
    nr number;
    nup exception;
begin
    select count(*) into nr
    from departments d
    where (select count(*) from employees 
           where department_id = d.department_id 
                 and salary between (val - 1000) and (val + 1000)) <> 0;
    
    if nr = 0 then
      raise nup;
    end if;
    dbms_output.put_line(nr);
exception
    when nup then
      dbms_output.put_line('Niciun departament');
end;
/

-- Ex 5
-- a
declare
    nr number;
    exp exception;
begin
    select count(*) into nr
    from employees
    where department_id not in (select department_id from departments);
    
    if nr = 0 then 
        raise exp;
    end if;
    
    delete employees
    where department_id not in (select department_id from departments);
    dbms_output.put_line('blabla');
exception
    when exp then
        raise_application_error(-20200, 'niciun angajat nu lucreaza in departament inexistent');
end;
/
rollback;
select * from employees;
delete employees
where employee_id = 178; 

-- b
declare
    nr number;
    exp exception;
begin
    select count(*) into nr
    from employees e
    where salary * commission_pct > 
          (((select distinct salary from employees where employee_id = e.manager_id) + salary) / 2);
    
    if nr = 0 then 
        raise exp;
    end if;
    
    delete employees e
    where commission_pct > 
          (((select distinct salary from employees where employee_id = e.manager_id) + salary) / 2);
    dbms_output.put_line('blabla');
exception
    when exp then
        raise_application_error(-20200, 'niciun angajat cu comisionul specificat');
end;
/

-- Ex 6
create or replace trigger min_sal_1000
before insert on employees
for each row
when (new.salary < 1000)
begin
    raise_application_error(-20200, 'Nu se pot insera angajati cu salariul mai mic de 1000');
end;
/
set serveroutput on
declare
    min_sal_1000 exception;
    pragma exception_init(min_sal_1000, -20200);
begin
    insert into employees (employee_id, last_name, email, hire_date, job_id, salary)
    values(700, 'Popescu', 'povescu@popescu', sysdate, 'IT_PROG', 100);
exception
    when min_sal_1000 then
        dbms_output.put_line('Salariul trebuie sa fie minim 1000');
        dbms_output.put_line('Mesaj trigger: ' || sqlerrm);
end;
/

-- Ex 7

declare
    dep departments.department_id%type := &dep;
    emp employees.employee_id%type;
    sal employees.salary%type;
begin
    select employee_id, salary into emp, sal
    from employees e
    where department_id = dep and salary = (select min(salary) from employees where department_id = dep);
    
    insert into mesaj
    values(emp || ' '|| sal);
exception
    when no_data_found then
        raise_application_error(-20201, 'Nu s-au gasit date');
    when too_many_rows then
        raise_application_error(-20202, 'Mai multi salariati cu salariul minim');
end;
/

-- Ex 8

declare
    c_instr number := 1;
    nume employees.last_name%type;
    sal employees.salary%type;
    vechime number; --employees.vechime%type;
    hire employees.hire_date%type;
    cod employees.employee_id%type;
begin
--    select last_name, salary, to_char(sysdate, 'yyyy') - to_char(hire_date, 'yyyy') 
--    into nume, sal, vechime
--    from employees
--    where salary = (select max(salary) 
--                    from employees
--                    where department_id = (select department_id
--                                           from employees
--                                           group by department_id
--                                           having avg(salary) = (select min(avg(salary))
--                                                           from employees
--                                                           group by department_id)));
    c_instr := c_instr + 1;
    select employee_id, hire_date into cod, hire
    from employees
    where salary = (select max(salary) 
                    from employees e join departments d on (e.department_id = d.department_id)
                         join locations l on (d.location_id = l.location_id)
                    where lower(city) = 'oxford');
    c_instr := c_instr + 1;
    select last_name, salary into cod, sal
    from employees
    where to_char(sysdate, 'yyyy') - to_char(hire_date, 'yyyy') = 
          (select min(to_char(sysdate, 'yyyy') - to_char(hire_date, 'yyyy'))
           from employees);
exception
    when too_many_rows then
        if c_instr = 1 then
            dbms_output.put_line('Mai mult de un angajat care respecta prima conditie');
        elsif c_instr = 2 then
            dbms_output.put_line('Mai mult de un angajat care respecta a doua conditie');
        else
            dbms_output.put_line('Mai mult de un angajat care respecta a treia conditie');
        end if;
end;
/
select to_char(sysdate, 'yyyy') - to_char(hire_date, 'yyyy') from employees;

-- Ex 9

declare
    diff number;
begin
    begin
        select salary/commission_pct into diff
        from employees
        where to_char(sysdate, 'yyyy') - to_char(hire_date, 'yyyy') = 
            (select max(to_char(sysdate, 'yyyy') - to_char(hire_date, 'yyyy'))
             from employees
             where commission_pct is not null)
             and commission_pct is not null;
        <<lala>>
        dbms_output.put_line('lalalalalala');
    exception
        when too_many_rows then 
        dbms_output.put_line('Tzeapa');
--        goto lala;
    end;
exception
    when zero_divide then 
        dbms_output.put_line('Nu mai impartii la zero :p');
end;
/

-- Ex 10

declare
    e1 exception;
    e2 exception;
begin
    begin
        raise e1;
    exception
        when e2 then
            dbms_output.put_line('ex2');
    end;
exception
    when e1 then
        dbms_output.put_line('ex1');
end;
/

-- Ex 11
begin
    declare
        nr number := 'bla';
    begin
        select count(*) into nr
        from departments
        where department_id in (select department_id from employees);
    exception
        when others then
            dbms_output.put_line('bloc intern');
    end;
exception
    when others then
        dbms_output.put_line('bloc extern');
end;
/

-- Ex 12

declare
    e1 exception;
    e2 exception;
begin
    begin
        raise e1;
    exception
        when e1 then
            raise e2;
        when e2 then
            dbms_output.put_line('bloc intern');
    end;
exception
    when e2 then
        dbms_output.put_line('bloc extern');
end;
/

-- Ex 13
select line, position, text
from user_errors
where upper(name) = upper('add_emp');

select line, position, text
from user_errors
where upper(name) = upper('add_job');

set serveroutput on