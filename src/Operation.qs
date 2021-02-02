namespace Cost {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    operation ApplyDriver(beta: Double[], n: Int, target: Qubit[]) : Unit {
        for i in 0..(n-1) {
            Rz(beta[3*i], target[i]);
            Rx(beta[3*i+1], target[i]);
            Rz(beta[3*i+2], target[i]);
        }
    }

    operation ApplyEntangler(gamma: Double[], n: Int, conn: Int, target: Qubit[]) : Unit {
        mutable i_gamma=0;
        for i_conn in 1..conn {
            for i_q in 0..n-i_conn-1  {
                    H(target[i_q]);
                    H(target[i_q+i_conn]);
                    CNOT(target[i_q], target[i_q+i_conn]);
                    Rz(gamma[i_gamma], target[i_q+i_conn]);
                    CNOT(target[i_q], target[i_q+i_conn]);
                    H(target[i_q]);
                    H(target[i_q+i_conn]);
                    set i_gamma+=1;    
            }                  
        }
    }

    @EntryPoint()
    operation AllocateQubitsandRunCircuit(n: Int, parameters: Double[], conn: Int, layers: Int) : Result[] {
        let length_beta=3*n;
        let length_gamma=n*conn-conn*(conn+1)/2;

        use target = Qubit[n] {
            for i_layer in 0..layers-2 {

                let beta=parameters[(length_beta+length_gamma)*i_layer..(length_beta+length_gamma)*i_layer+length_beta-1];
                let gamma=parameters[(length_beta+length_gamma)*i_layer+length_beta..(length_beta+length_gamma)*(i_layer+1)-1];
                ApplyEntangler(gamma, n, conn, target);
                ApplyDriver(beta, n, target);
            }

            let gamma_end=parameters[(length_beta+length_gamma)*(layers-1)..(length_beta+length_gamma)*(layers-1)+length_gamma-1];
            ApplyEntangler(gamma_end, n, conn, target);
            
            return MultiM(target);
        }
    }
}
