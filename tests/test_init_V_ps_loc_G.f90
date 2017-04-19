PROGRAM test_init_V_ps_loc_G

  USE m_PsPot, ONLY : PsPot_Dir
  USE m_LF3d, ONLY : Npoints => LF3d_Npoints, &
                     dVol => LF3d_dVol
  USE m_states, ONLY : Nstates, Focc, &
                       evals => KS_evals, &
                       evecs => KS_evecs

  IMPLICIT NONE 
  INTEGER :: Narg
  INTEGER :: NN(3)
  REAL(8) :: AA(3), BB(3)
  CHARACTER(64) :: filexyz
  INTEGER :: ip, ist

  Narg = iargc()
  IF( Narg /= 1 ) THEN 
    WRITE(*,*) 'ERROR: exactly one argument must be given'
    STOP 
  ENDIF 

  CALL getarg(1,filexyz)

  CALL init_atoms_xyz(filexyz)

  ! Override PsPot_Dir
  PsPot_Dir = '../HGH/'
  CALL init_PsPot()

  CALL info_atoms()
  CALL info_PsPot()

  !
  NN = (/ 55, 55, 55 /)
  AA = (/ 0.d0, 0.d0, 0.d0 /)
  BB = (/ 16.d0, 16.d0, 16.d0 /)
  CALL init_LF3d_p( NN, AA, BB )
  CALL info_LF3d()

  CALL init_strfact()

  CALL calc_Ewald()

  CALL alloc_hamiltonian()

  CALL init_nabla2_sparse()
  CALL init_ilu0_prec()

  CALL init_V_ps_loc_G()

  ! Initialize electronic states variables
  Nstates = 1

  ALLOCATE( evecs(Npoints,Nstates), evals(Nstates) )
  ALLOCATE( Focc(Nstates) )

  Focc(:) = 1.d0

  DO ist = 1, Nstates
    DO ip = 1, Npoints
      CALL random_number( evecs(ip,ist) )
    ENDDO
  ENDDO
  CALL orthonormalize( Nstates, evecs )
  CALL ortho_check( Npoints, Nstates, dVol, evecs )

  !CALL KS_solve_Emin_cg( 3.d-5, 200, .FALSE. )
  !CALL KS_solve_Emin_cg( 3.d-4, 200, .FALSE. )
  CALL KS_solve_Emin_pcg( 3.d-5, 200, .FALSE. )

  CALL info_energies()

  DEALLOCATE( evecs, evals )
  DEALLOCATE( Focc )


  CALL dealloc_nabla2_sparse()
  CALL dealloc_ilu0_prec()
  CALL dealloc_hamiltonian()
  CALL dealloc_LF3d()
  CALL dealloc_PsPot()
  CALL dealloc_atoms()

END PROGRAM 