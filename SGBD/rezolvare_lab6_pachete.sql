-- Pachete

-- definire:
-- Obs: procedurile private se pun doar in body
CREATE PACKAGE nume_pachet {IS | AS} -- specificatia
/* interfata utilizator, care contine: declaratii de tipuri si obiecte
publice, specificatii de subprograme */
END [nume_pachet];
/

CREATE PACKAGE BODY nume_pachet {IS | AS} -- corpul
/* implementarea, care contine: declaratii de obiecte si tipuri private,
corpuri de subprograme specificate în partea de interfata */
[BEGIN]
/* instructiuni de initializare, executate o singura data când
pachetul este invocat prima oara de catre sesiunea utilizatorului */
END [nume_pachet];
/

-- Pachete predefinite: dbms_output, dbms_sql, dbms_job, utl_file

-- Pachete definite de utilizator:
-- 1. a)
create or replace package dept_pkg is
    procedure add_dept(d_id in dept_copy.department_id%type,  
                       d_name in dept_copy.department_name%type,
                       man_id in dept_copy.manager_id%type,
                       loc_id in dept_copy.location_id%type);
    procedure upd_dept(d_id in dept_copy.department_id%type,
                       d_name in dept_copy.department_name%type);
    procedure del_dept(d_id in dept_copy.department_id%type);
    function get_dept (d_id in dept_copy.department_id%type) 
            return dept_copy.department_name%type;
end dept_pkg;
/
show errors

create or replace package body dept_pkg is
    procedure add_dept(d_id in dept_copy.department_id%type, 
                       d_name in dept_copy.department_name%type,
                       man_id in dept_copy.manager_id%type,
                       loc_id in dept_copy.location_id%type) is
    begin
        insert into dept_copy
        values(d_id, d_name, man_id, loc_id);
--        commit;
    end add_dept;
    
    procedure upd_dept(d_id in dept_copy.department_id%type,
                       d_name in dept_copy.department_name%type) is 
    begin
        update dept_copy
        set department_name = d_name
        where department_id = d_id;
    end upd_dept;
    
    procedure del_dept(d_id in dept_copy.department_id%type) is
    begin
        delete from dept_copy
        where department_id = d_id;
        
        if sql%notfound then
            raise_application_error(-20123, 'Nu exista departament cu id-ul ' || d_id);
        end if;
    end del_dept;
    
    function get_dept (d_id in dept_copy.department_id%type) 
            return dept_copy.department_name%type is
    v_name dept_copy.department_name%type;
    begin
        select department_name into v_name
        from dept_copy
        where department_id = d_id;
        
        return v_name;
    end get_dept;
end dept_pkg;
/

select * from dept_copy;
-- b
execute dept_pkg.add_dept(700, 'Iepuri', 100, 1700);
execute dept_pkg.upd_dept(700, 'Iepuri pufosi');
execute dept_pkg.del_dept(700);
set serveroutput on
execute dbms_output.put_line('Departamentul cu id-ul 50: ' || dept_pkg.get_dept(50));

BEGIN
    dept_pkg.add_dept(12, 'Iepurasi pufosi', 100, 1700);
    dept_pkg.upd_dept(12, 'Catei');
    dept_pkg.del_dept(12);
END;
/

select dept_pkg.get_dept(50)
from dual;

-- 2
create or replace 
package emp_pkg is
    procedure add_emp(--p_id in emp_copy.employee_id%type, 
                      p_name in emp_copy.last_name%type, 
                      p_email in emp_copy.email%type, 
                      p_job in emp_copy.job_id%type,
                      p_hire_date in emp_copy.hire_date%type);
    procedure get_emp(p_id in emp_copy.employee_id%type, 
                      p_sal out emp_copy.salary%type,
                      p_job out emp_copy.job_id%type);
    procedure add_emp(p_fname in emp_copy.first_name%type, 
                      p_lname in emp_copy.last_name%type, 
                      p_job in emp_copy.job_id%type);                  
    function get_emp(p_emp_id employees.employee_id%type) return employees%rowtype;
    function get_emp(p_nume employees.last_name%type) return employees%rowtype;
    procedure print_employee(emp in employees%rowtype);
end emp_pkg;
/

create or replace 
package body emp_pkg is
    
--    FUNCTIE PRIVATA!!
--     function valid_job_id (p_job in jobs.job_id%type) return boolean is
--        x pls_integer;
--     begin
--        select 1 into x
--        from jobs
--        where lower(job_id) = lower(p_job);
--        return true;
--     exception
--        when no_data_found then
--        return false;
--     end valid_job_id;
     
     procedure add_emp(--p_id in emp_copy.employee_id%type, 
                      p_name in emp_copy.last_name%type, 
                      p_email in emp_copy.email%type, 
                      p_job in emp_copy.job_id%type,
                      p_hire_date in emp_copy.hire_date%type) is 
    begin
        insert into emp_copy (employee_id, last_name, email, job_id, hire_date)
        values(id_emp.nextval, p_name, p_email, p_job, p_hire_date);
    end add_emp;                  
                      
    procedure get_emp(p_id in emp_copy.employee_id%type, 
                      p_sal out emp_copy.salary%type,
                      p_job out emp_copy.job_id%type) is
    begin
        select salary, job_id into p_sal, p_job
        from emp_copy
        where employee_id = p_id;
    end get_emp;
    
    procedure add_emp(--p_id in emp_copy.employee_id%type, 
                      p_fname in emp_copy.first_name%type, 
                      p_lname in emp_copy.last_name%type, 
                      p_job in emp_copy.job_id%type) is 
    v_email emp_copy.email%type;
    begin
        v_email := upper(substr(p_fname, 1, 1) || substr(p_lname, 1, 7));
        add_emp(p_lname, v_email, p_job, sysdate);
    end add_emp; 
    
    function get_emp(p_emp_id employees.employee_id%type) return employees%rowtype is
        emp employees%rowtype;
    begin
        select * into emp
        from employees
        where employee_id = p_emp_id;
        
        return emp;
    end get_emp;
    function get_emp(p_nume employees.last_name%type) return employees%rowtype is
        emp employees%rowtype;
    begin
        select * into emp
        from employees
        where last_name = p_nume;
        
        return emp;
    end get_emp;
    procedure print_employee(emp in employees%rowtype) is
    begin
        dbms_output.put_line('Departament: ' || emp.department_id);
        dbms_output.put_line(' Cod ang: ' || emp.employee_id);
        dbms_output.put_line(' Prenume: ' || emp.first_name);
        dbms_output.put_line(' Nume: ' || emp.last_name);
        dbms_output.put_line(' Job: ' || emp.job_id);
        dbms_output.put_line(' Salary: ' || emp.salary);
    end print_employee;
end emp_pkg;
/
--declare
--    rand employees%rowtype;
--begin
--    select * into rand
--    from employees
--    where employee_id = 100;
--    
--    dbms_output.put_line('sal:' || rand.salary);
--end;
--/

select * from emp_copy;

-- ex 7
create or replace package ex7 as
--    cursor c_nume(oras locations.city%type) return employees%rowtype;
    cursor emp_sal_maxim (sal number) return employees%rowtype;
    function sal_max_oras (oras locations.city%type) return employees.salary%type;
end ex7;
/
create or replace package body ex7 is
--    cursor c_nume(oras locations.city%type) is (select max(salary)
--                                                from employees e join departments d on (e.department_id = d.department_id)
--                                                     join locations l on (l.location_is = d.location_id)
--                                                where lower(city) = lower(oras);
--                                                )
    cursor emp_sal_maxim(sal number) return employees%rowtype
                                     is (select * 
                                         from employees
                                         where salary >= sal);
    function sal_max_oras (oras locations.city%type) return employees.salary%type is
      sal_max employees.salary%type;
    begin
        select max(salary) into sal_max
--        from employees e join departments d on (e.department_id = d.department_id)
--             join locations l on (l.location_id = d.location_id)
        from employees e, departments d, locations l
        where e.department_id = d.department_id and l.location_id = d.location_id and lower(city) = lower(oras);
        
        return sal_max;
    end sal_max_oras;
end ex7;
/

SET SERVEROUTPUT ON
DECLARE
    v_oras locations.city%TYPE:= 'Oxford';
    v_max NUMBER;
    v_emp employees%ROWTYPE;
BEGIN
    v_max:= ex7.sal_max_oras(v_oras);
    
    OPEN ex7.emp_sal_maxim(v_max);
    
    LOOP
        FETCH ex7.emp_sal_maxim INTO v_emp;
        EXIT WHEN ex7.emp_sal_maxim%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_emp.last_name||' '||v_emp.salary);
    END LOOP;
    
    CLOSE ex7.emp_sal_maxim;
END;
/
--SET SERVEROUTPUT OFF

-- 8
create or replace package ex8_verifyjd is
    procedure verify (j jobs.job_id%type, d employees.department_id%type);
end ex8_verifyjd;
/

create or replace package body ex8_verifyjd is
    procedure verify (j jobs.job_id%type, d employees.department_id%type) is
        type t_emp is table of employees.employee_id%type;
        emp t_emp;
    begin
        select unique employee_id bulk collect into emp
        from employees
        where job_id = j and department_id = d;
        
        if sql%notfound then
            raise_application_error(-20325, 'Nu exista aceasta combinatie');
        end if;
        
        dbms_output.put_line('Combinatia exista');
    end verify;
end ex8_verifyjd;
/
set serveroutput on
begin
    ex8_verifyjd.verify('IT_PROG', 10);
end;
/
execute ex8_verifyjd.verify('IT_PROG', 60);
--select unique * from (select job_id, department_id from employees) order by department_id;

-- Pachete standard
-- dbms_output

-- dbms_job
-- 10
--VARIABLE num_job NUMBER
--
--BEGIN
--    DBMS_JOB.SUBMIT(job => :num_job, ---- returneaz num rul jobului, printr-o variabil de leg tur
--                    what => 'ex8_verifyjd.verify(‘SA_MAN’, 20);' --–codul care va fi executat ca job
--                    next_date => SYSDATE+1/288, -- data primei executiei
--                    interval => 'TRUNC(SYSDATE+1)'); -- intervalul dintre execu iile job-ului
--    COMMIT;
--END;
--/
--PRINT num_job
--b) Afla i informa ii despre job-urile curente în vizualizarea USER_JOBS.
--SELECT job, next_date,what
--FROM user_jobs;
--c) Identifica i în coada de a teptare job-ul pe care l-a i lansat i executa i-l.
--BEGIN
--DBMS_JOB.RUN(job => x); --x este num rul identificat
----pentru job-ul care v apar ine
--END;
--/
