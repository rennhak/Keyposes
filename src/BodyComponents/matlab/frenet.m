
function frenet()

X                               = csvread( 'data.csv' );
[ kappa, tau, T, N, B, s, ds]   = frenetframe( X, 0.001 );

csvwrite( 'kappa.csv', kappa  );
csvwrite( 'tau.csv', tau      );
csvwrite( 'T.csv', T          );
csvwrite( 'N.csv', N          );
csvwrite( 'B.csv', B          );

