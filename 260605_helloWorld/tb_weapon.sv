
class weapon;
    string name;
    function new(string name);
        this.name = name;
    endfunction  //new()

    virtual function void shot();
        $display("      [%s] ...(무기 없음)", name);
    endfunction
endclass  //weapon

class M16 extends weapon;
    string name;
    function new(string name);
        super.new(name);
    endfunction  //new()

    virtual function void shot();
        $display("      [%s] ...(탕탕탕)", name);
    endfunction
endclass  //weapon

class AUG extends weapon;
    string name;
    function new(string name);
        super.new(name);
    endfunction  //new()

    virtual function void shot();
        $display("      [%s] ...(텅텅텅)", name);
    endfunction
endclass  //weapon

class K2 extends weapon;
    string name;
    function new(string name);
        super.new(name);
    endfunction  //new()

    virtual function void shot();
        $display("      [%s] ...(퓽퓽퓽)", name);
    endfunction
endclass  //weapon


module tb_weapon ();
    weapon BlackPink = new("No weapon");

    M16 m16 = new("M16");
    AUG aug = new("AUG");
    K2 k2 = new("K2");

    initial begin
        $display("======다형성 데모=======");
        BlackPink.shot();

        $display("======무기 M16으로 변경=======");
        BlackPink = m16;
        BlackPink.shot();

        $display("======무기 AUG으로 변경=======");
        BlackPink = aug;
        BlackPink.shot();

        $display("======무기 K2로 변경=======");
        BlackPink = k2;
        BlackPink.shot();


        $finish;
    end
endmodule
