    class checker_base;

        test_cfg_base cfg;

        bit done;
        int cnt;
        bit in_reset;

        mailbox#(packet) in_mbx;
        mailbox#(packet) out_mbx;

        virtual task run();
            packet tmp_p;
            forever begin
                wait(~in_reset);
                fork
                    do_check();
                    wait(in_reset);
                join_any
                disable fork;
                if( done ) break;
                while(in_mbx.try_get(tmp_p)) cnt = cnt + tmp_p.tlast;
            end
        endtask

        virtual task check(packet in, packet out);
            tid_eq_a: assert( in.tid === out.tid );
            tid_eq_c: cover( in.tid === out.tid );
            tdata_eq_a: assert( out.tdata === in.tdata ** 5 );
            tdata_eq_c: cover( out.tdata === in.tdata ** 5 );
            tlast_eq_a: assert( in.tlast === out.tlast );
        endtask

        virtual task do_check();
            packet in_p, out_p;
            forever begin
                in_mbx.get(in_p);
                out_mbx.get(out_p);
                check(in_p, out_p);
                cnt = cnt + out_p.tlast;
                if( cnt == cfg.master_pkt_amount ) begin
                    done = 1;
                    break;
                end
            end
        endtask

    endclass