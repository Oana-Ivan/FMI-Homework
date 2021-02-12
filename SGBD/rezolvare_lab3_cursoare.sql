-- CURSOARE

? Etapele utilizarii unui cursor:
a) Declarare (în sectiunea declarativa a blocului PL/SQL):
    CURSOR c_nume_cursor [ (parametru tip_de_Date, ..)] IS
    comanda select;

b) deschidere (comanda open), operatie ce identific? mul?imea de linii (active set):
    OPEN c_nume_cursor [ (parametru, ...)];

c) Incarcare (comanda FETCH ). Numarul de variabile din clauza INTO trebuie sa se potriveasca cu
    lista SELECT returnata de cursor.
    FETCH c_nume_cursor INTO variabila, ...;

d) Verificare dac? nu am ajuns cumva la finalul mul?imii de linii folosind atributele:
    C_nume_cursor%NOTFOUND – valoare booleana
    C_nume_cursor%FOUND – valoare booleana
    Daca nu s-a ajuns la final mergi la c).

e) Inchidere cursor (operatiune foarte importanta avand in vedere ca daca nu e inchis cursorul
ramane deschis si consuma din resursele serverului, max_open_cursors)
    close c_nume_cursor;

-- ex 1
declare
    cursor c_com is (select employee_id from angajati where salary > (&valoare));
    v_cod angajati.employee_id%type;
begin
    open c_com;
--    select employee_id bulk collect into  
    loop
        fetch c_com into v_cod;
        exit when c_com%notfound;
        update angajati
        set commission_pct = commission_pct * 1.1
        where employee_id = v_cod;
        dbms_output.put_line(v_cod);
    end loop;
    
    dbms_output.put_line(sql%rowcount);
    
    close c_com;
end;
/
select commission_pct, salary from angajati order by salary desc;
set serveroutput on
-- ex 2

create table lab3_ex2_dep
(cod_dep number(4), cod_ang varchar2(25));
delete from lab3_ex2_dep;
SET SERVEROUTPUT ON
DECLARE
    TYPE t_dep IS TABLE OF NUMBER;
    V_dep t_dep;
BEGIN
    select department_id bulk collect into v_dep from emp;
    
    forall j in 1..v_dep.count
          insert into lab3_ex2_dep
          select distinct department_id, employee_id
          FROM emp
          WHERE department_id = v_dep(j);
    
    FOR j IN 1..v_dep.COUNT LOOP
          dbms_output.put_line ('Pentru departamentul avand codul ' ||
                                 v_dep(j) || ' au fost inserate ' ||
                                 sql%bulk_rowcount(j)
                                 || 'inregistrari (angajati)');
    end loop;
    
    DBMS_OUTPUT.PUT_LINE ('Numarul total de inregistrari inserate este '||SQL%ROWCOUNT);
END;
/
SET SERVEROUTPUT OFF

-- Cursoare expricite
DECLARE
    CURSOR c_emp IS
          SELECT last_name, salary*12 sal_an
          from emp
          WHERE department_id = 50;
    V_emp c_emp%ROWTYPE;
BEGIN
    open c_emp;
    
    FETCH c_emp INTO v_emp;
    while (c_emp%found) loop
        DBMS_OUTPUT.PUT_LINE (' Nume: ' || v_emp.last_name ||' are salariul anual : ' || v_emp.sal_an);
        fetch c_emp into v_emp;
    end loop;  
    CLOSE c_emp;
end;
/
declare 
    cursor ang is
          select last_name, salary*12 sal_an
          from emp
          where department_id = 50;
    j ang%rowtype;
begin
--    open ang;
    
--    loop
--        fetch ang into j;
--        exit when ang%notfound;
--        dbms_output.put_line('<'|| j.last_name || '> are sal anual = <' || j.sal_an || '>');
--    end loop;
        
--    close ang;
      for j in ang loop
         if j.sal_an > 40000 then
         dbms_output.put_line('<'|| j.last_name || '> are sal anual = <' || j.sal_an || '>');
         end if;
      end loop;
end;
/
-- Parametri
-- ex 7
DECLARE
    CURSOR c_nume (p_id employees.employee_id%TYPE) IS
        SELECT last_name, salary
        FROM employees
        WHERE p_id IS NULL OR employee_id = p_id;
    V_nume c_nume%ROWTYPE;
BEGIN
    open c_nume (104);
    
    LOOP
      FETCH c_nume INTO v_nume;
      exit when c_nume%notfound;
      DBMS_OUTPUT.PUT_LINE (' Nume: ' || v_nume.last_name || ', salariu : ' || v_nume.salary);
    end loop;
    
    CLOSE c_nume;
END;
/
create table mesaje (mesaj varchar2(100));
-- ex 9
DECLARE
    v_cod_dep departments.department_id%type;
    v_cod_job employees.job_id%TYPE;
    v_mesaj varchar2(75);
    
    CURSOR dep_job IS
        SELECT department_id, job_id
        from emp;
        
    CURSOR emp_cursor (v_id_dep NUMBER,v_id_job VARCHAR2) IS
        SELECT employee_id || department_id || job_id
        FROM emp
        WHERE department_id = v_id_dep AND job_id = v_id_job;
BEGIN
      open dep_job;
      
      loop
          fetch dep_job into v_cod_dep, v_cod_job;
          exit when dep_job%notfound;
          
          IF emp_cursor%ISOPEN THEN CLOSE emp_cursor;
          end if;
          
          open emp_cursor (v_cod_dep, v_cod_job);
          
          LOOP
              FETCH emp_cursor INTO v_mesaj;
              exit when emp_cursor%notfound;
              
              INSERT INTO mesaje 
              VALUES (v_mesaj);
          end loop;
          
          CLOSE emp_cursor;
      end loop;
      
      CLOSE dep_job;
      COMMIT;
END;
/
-- for update
-- ex 10
DECLARE
    CURSOR before95 IS
        select *
        from emp
        WHERE commission_pct IS NULL AND hire_date <= TO_DATE('01-JAN-1995','DD-MON-YYYY')
    FOR UPDATE OF salary NOWAIT;
BEGIN
    FOR x IN before95 LOOP
        UPDATE emp
        SET salary = salary*2
        WHERE CURRENT OF before95;
    END LOOP;
    COMMIT; -- se permanentizeaza actiunea si se elibereaza blocarea
END;
/
-- dinamice
ACCEPT p_optiune PROMPT ‘Introduceti optiunea (1,2 sau 3) ‘
DECLARE
    TYPE emp_tip IS REF CURSOR RETURN emp_pnu%ROWTYPE;
    v_emp emp_tip;
    V_optiune NUMBER := &p_optiune;
BEGIN
      IF v_optiune = 1 THEN
      OPEN v_emp FOR SELECT * FROM emp_pnu;
      --!!! Introduce i cod pentru afi are
      ELSIF v_optiune = 2 THEN
      OPEN v_emp FOR SELECT * FROM emp_pnu
      WHERE salary BETWEEN 10000 AND 20000;
      --!!! Introduce i cod pentru afi are
      ELSIF v_optiune = 3 THEN
      OPEN emp_pnu FOR SELECT * FROM emp_pnu
      WHERE TO_CHAR(hire_date, ‘YYYY’) = 1990;
      --!!! Introduce i cod pentru afi are
      ELSE
      DBMS_OUTPUT.PUT_LINE(‘Optiune incorecta’);
      END IF;
END;
/


