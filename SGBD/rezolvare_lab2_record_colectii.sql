-- Rezolvare lab 2 - VSL
set serveroutput on
-- I. RECORD: insert, update, delete

-- ex 1
<<ex1_delete>>
declare
    type ang is record (
    cod employees.employee_id%type,
    nume employees.first_name%type,
    salariu employees.salary%type,
    dep employees.department_id%type
    );
    
    v_ang_200 ang;
begin
    delete angajati
    where employee_id = 201
    returning employee_id, first_name, salary, department_id into v_ang_200;
    
    dbms_output.put_line('S-a sters angajatulul cu urmatoarele date: '
                          || v_ang_200.cod || ', ' || v_ang_200.nume || ', '
                          || v_ang_200.salariu || ', ' || v_ang_200.dep);
    
end;
/
rollback;

-- ex 2
<<ex2_insert_update>>
declare
    type ang is record (
    cod angajati.employee_id%type := 1,
    nume angajati.first_name%type := 'Popescu',
    prenume angajati.last_name%type := 'Andrei',
    email angajati.email%type := 'andrei@andrei.andrei',
    tel angajati.phone_number%type := '0768224966',
    data angajati.hire_date%type := sysdate,
    job angajati.job_id%type := 'IT_PROG',
    salariu angajati.salary%type := 2300,
    comision angajati.commission_pct%type,
    man angajati.manager_id%type := 100,
    dep angajati.department_id%type := 30,
    vec angajati.vechime%type := null
    );
    
    v_ang_nou ang;
begin
    -- insert
    insert into angajati
    values(v_ang_nou);
    
    dbms_output.put_line('S-a introdus angajatulul cu urmatoarele date: '
                          || v_ang_nou.cod || ', ' || v_ang_nou.nume || ', '
                          || v_ang_nou.salariu || ', ' || v_ang_nou.dep);
    -- actualizare
    
--    v_ang_nou.salariu = 3000;
--    
--    update angajati
--    set row = v_ang_nou
--    where employee_id = v_ang_nou.cod;
end;
/
-- cod lab: 
set serveroutput on
DECLARE
    TYPE info_ang_pnu IS RECORD (
    cod_ang NUMBER(4):=500,
    nume  VARCHAR2(20):='abc',
    prenume VARCHAR2(20):='john',
    email angajati.email%TYPE:='abc@mail',
    telefon angajati.phone_number%type,
    data angajati.hire_date%type:=sysdate,
    job angajati.job_id%TYPE:='SA_REP',
    salariu NUMBER(8, 2):=1000,
    comision angajati.commission_pct%type,
    manager angajati.manager_id%TYPE,
    cod_dep number(4):=30,
    vec angajati.vechime%type := null
    );
    
    v_info_ang info_ang_pnu;
      BEGIN
      --inserare; nu ar fi fost posibila maparea unei variabile de tip RECORD într-o lista
      -- explicita de coloane
      INSERT INTO angajati
      values v_info_ang;
      
      DBMS_OUTPUT.PUT_LINE('A fost introdusa linia continand valorile ' ||
                              v_info_ang.cod_ang ||' '||v_info_ang.nume||' ' ||v_info_ang.salariu ||' '
                              || v_info_ang.cod_dep) ;
      --actualizare
      v_info_ang.nume:='smith';
      UPDATE angajati
      SET ROW=v_info_ang
      where employee_id = v_info_ang.cod_ang;
      
      DBMS_OUTPUT.PUT_LINE('A fost actualizata linia cu valorile ' ||
                            v_info_ang.cod_ang ||' '||v_info_ang.nume||' ' ||v_info_ang.salariu ||' '
                            || v_info_ang.cod_dep) ;
END;
/

-- II. COLECTII
 - tablouri indexate (index-by tables); -- numai in declaratii PL/SQL
 - tablouri imbricate (nested tables);
 - vectori (varrays sau varying arrays).
-- diferenta tablouriindexate - cele imbricate = clauza INDEX BY

-- ex 3
declare
--    Declarare tipuri de date colectii
    type tab_index is table of number
    index by binary_integer; -- !!!! tabel indexat
    
    type tab_imbri is table of number; -- tab imbricat
    
    type vector is varray(15) of number; -- vector
    
--    Declarare variabile de tipurile colectie declarate mai sus
    v_tab_index tab_index;
    v_tab_imbri tab_imbri;
    v_vector vector;
    
    i INTEGER;
begin
--      Dam valori variabilelor de tip colectie
      v_tab_index(1) := 72;
      v_tab_index(2) := 23;
      
      v_tab_imbri := tab_imbri(5, 3, 2, 8, 7);
      
      v_vector := vector(1, 2);
      
      -- afisati valorile variabilelor definite; exemplu dat pentru v_tab_imbri
      i := v_tab_imbri.FIRST;
      while (i <= v_tab_imbri.last) loop
          dbms_output.put_line('v_tab_imbri: ' || v_tab_imbri(i));
          i := v_tab_imbri.NEXT(i);
      end loop;
      
      i := v_tab_index.FIRST;
      while (i <= v_tab_index.last) loop
          dbms_output.put_line('v_tab_index: ' || v_tab_index(i));
          i := v_tab_index.NEXT(i);
      end loop;
      
       i := v_vector.first;
      while (i <= v_vector.last) loop
          dbms_output.put_line('v_vector: ' || v_vector(i));
          i := v_vector.next(i);
      END LOOP;
END;
/

-- II.1. TABLOURI INDEXATE
--? tabloul indexat pl/sql are dou? componente:
-- -  coloan? ce cuprinde cheia primar? pentru acces la liniile tabloului
-- -  o coloan? care include valoarea efectiv? a elementelor tabloului.
-- -  NU au constructori (spre deosebire de celelalte) 
--? Declararea tipului TABLE se face respectând urm?toarea sintax?:
type nume_tip is table of
  {tip_coloan? | variabil?%TYPE |
  nume_tabel.coloan?%TYPE [NOT NULL] |
  nume_tabel%ROWTYPE}
index by tip_indexare;
/
obs:
pot avea chei arbitrare, 
dimensiune dinamica
fara initializare si declarare simultana
referire la o linie care nu exista => no_data_found

declare
  type ex3_tip is table of number
  index by binary_integer;
  
  ex3 ex3_tip;
  j integer;
begin
  for i in 1..20 loop
    ex3(i) := i;
  end loop;
  
  j := ex3.first;
  while (j <= ex3.last) loop
     dbms_output.put_line('ex3(' || j || '): ' || ex3(j));
     j := ex3.NEXT(j);
  end loop;
  
  dbms_output.put_line('Before delete: ' || ex3.count);
  ex3.delete;
  dbms_output.put_line('After delete: ' || ex3.count);
  
  dbms_output.put_line('lalalalala');
end;
/

-- II.2. VECTORI
-- dim maxima constanta, stabilita a declarare
-- folositi pentru modelarea relatiilor one to many
-- fiecare element are index, indexul incepe de la 1
--? Tipul de date vector este declarat utilizând sintaxa:
type nume_tip is {varray | varying array} (lungime_maxim?) of tip_elemente [not null];
--
create type nume_tip as {table | varray} of tip_elemente;

-- ex 6
DECLARE
    type secventa is varray(5) of varchar2(10);
    
    v_sec secventa := secventa('alb', 'negru', 'rosu', 'verde');
BEGIN
    v_sec (3) := 'rosu';
    dbms_output.put_line(to_char(v_sec.count));
    v_sec.extend; -- adauga un element null, nu da eroare pt ca v_secventa are doar 4 elemente si maximul e de 5
    v_sec(5) := 'albastru';
    dbms_output.put_line(to_char(v_sec.count));
    -- extinderea la 6 elemente va genera eroarea ORA-06532, maximul e de 5 elemente
--    v_sec.EXTEND;
END;
/
-- ex 7
-- a
create type proiect as varray(50) of varchar2(15);
-- b
create table test (cod_ang number(4), proiecte_alocate proiect);
-- relatie one to many
-- c
declare
  v_vector proiect := proiect();
begin
  -- introducem 3 valori
  for i in 1..3 loop
      v_vector.extend;
      v_vector(i) := 'proiect ' || i;
  end loop;
  insert into test
  values(101, v_vector);
  dbms_output.put_line(v_vector(3));
end;
/
-- ex 8
declare
  type lista_angajati is varray(200) of number(3);
  v_ang50_marire lista_angajati := lista_angajati();
begin
  select employee_id bulk collect into v_ang50_marire
  from angajati
  where salary < 5000 and department_id = 50;
  
  forall i in v_ang50_marire.first..v_ang50_marire.last
      update angajati
      set salary = salary * 1.1
      where employee_id = v_ang50_marire(i);
--  end loop
  
  dbms_output.put_line(to_char(v_ang50_marire.count));
end;
/
rollback;
select * from angajati where department_id = 50 and salary >= 3000;

-- II.3. TABLOURI IMBRICATE
-- precum tab indexate, dar fara dimensiune stabilita, ele cresc dinamic
-- indici nr consecutive !!, dar pot aparea  spatii goale prin stergere, sooo next pt urm element
-- pt a add un nou elem prima data extend(nr_comp)
-- CONSTRUCTOR(dimensiunea e data de nr de eemente din constructor, daca nu e niciunul => colectie vida cu valoarea not null)
--? Comanda de declarare a tipului de date tablou imbricat are sintaxa:
type nume_tip is table of tip_ elemente [not null];
set serveroutput on
-- EX 9
declare
  type ex9 is table of number(2);
  v_ex9 ex9 := ex9();
begin
  dbms_output.put_line(to_char(v_ex9.count));
  v_ex9.extend;
  v_ex9(1) := 12;
  for i in v_ex9.first..v_ex9.last loop
      dbms_output.put_line(v_ex9(i));
  end loop;
end;
/

DECLARE
    type chartab is table of char(1);
    
    v_Characters CharTab := CharTab('M', 'a', 'd', 'a', 'm', ',', ' ',
                                    'I', '''', 'm', ' ', 'A', 'd', 'a', 'm');
    v_Index INTEGER;
BEGIN
    v_Index := v_Characters.FIRST;
    WHILE v_Index <= v_Characters.LAST LOOP
        DBMS_OUTPUT.PUT(v_Characters(v_Index));
        v_Index := v_Characters.NEXT(v_Index);
    end loop;
    
    dbms_output.new_line;
    
    v_Index := v_Characters.LAST;
    WHILE v_Index >= v_Characters.FIRST LOOP
        DBMS_OUTPUT.PUT(v_Characters(v_Index));
        v_Index := v_Characters.PRIOR(v_Index);
    end loop;
    
    DBMS_OUTPUT.NEW_LINE;
END;
/
-- ex 10
declare
    type numtab is table of number(3);
    type numtab_index is table of number(3) index by binary_integer;
    v_nestedtable numtab := numtab(-7, 14.3, 3.14159, null, 0);
    v_count binary_integer := 1;
    v_indexbytable numtab_index;
begin
    loop
        -- verificam daca exista un element cu indicele v_count si il afisam
        if v_nestedtable.exists(v_count) then dbms_output.put_line( 'v_NestedTable(' || 
                                                                     v_count || '): ' ||
                                                                     v_nestedtable(v_count));
                                              -- copiem valoarea in tabelul indexat si marim contorul
                                              v_indexbytable(v_count) := v_nestedtable(v_count);
                                              v_count := v_count + 1;
        else exit;
        end if;
    end loop;
    -- s-au copiat datele, ambele tabele au aceleasi valori
    dbms_output.put_line('-------------------------------------------');
    -- atribuire invalida
    -- v_IndexByTable := v_NestedTable;
    v_count := v_indexbytable.count;
    
    -- afisam informatia parcurgand invers tabloul indexat
    loop
        if v_indexbytable.exists(v_count) then
                  dbms_output.put_line( 'v_IndexByTable(' || v_count || '): ' ||
                                         v_indexbytable(v_count));
                  v_count := v_count - 1;
        else exit;
        end if;
    end loop;
end;
/
-- ex 11
declare
    type alfa is table of varchar2(50);
    -- creeaza un tablou (atomic) null
    tab1 alfa;
    /* creeaza un tablou cu un element care este null, dar
    tabloul nu este null, el este initializat, poate
    primi elemente */
    tab2 alfa := alfa();
begin
    if tab1 is null then dbms_output.put_line('tab1 este NULL');
    else dbms_output.put_line('tab1 este NOT NULL');
    end if;
    
    if tab2 is null then dbms_output.put_line('tab2 este NULL');
    else dbms_output.put_line('tab2 este NOT NULL');
    end if;
end;
/
-- rezultat:
--tab1 este null
--tab2 este NOT NULL

-- ex 12
declare
    type numar is table of integer;
    alfa numar;
begin
--    alfa(1) := 77; -- "Reference to uninitialized collection"
    -- declanseaza exceptia COLLECTION_IS_NULL
   
    alfa := numar(15, 26, 37);
    alfa(1) := ascii('X');
    alfa(2) := 10*alfa(1);
    
--    alfa('P') := 77;
--    /* declanseaza exceptia VALUE_ERROR deoarece indicele
--    nu este convertibil la intreg */

--    alfa(4) := 47;
--    /* declanseaza exceptia SUBSCRIPT_BEYOND_COUNT deoarece
--    indicele se refera la un element neinitializat */

--    alfa(null) := 7; -- declanseaza exceptia VALUE_ERROR
--    alfa(0) := 7; -- exceptia SUBSCRIPT_OUTSIDE_LIMIT
    alfa.delete(1);
    dbms_output.put_line(to_char(alfa.count));
--    if alfa(1) = 1 then ... -- exceptia NO_DATA_FOUND
--    ...
end;
/

-- II.5. Prelucrarea colectiilor
-- ex 13
set verify off
set serveroutput on
create type list_ang as varray(10) of number(4); 
