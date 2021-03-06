!
subroutine b4step2(mbc,mx,my,meqn,q,xlower,ylower,dx,dy,t,dt,maux,aux,mptr)
! ============================================
! 
! # called before each call to step
! # use to set time-dependent aux arrays or perform other tasks.
! 
! This particular routine sets negative values of q(1,i,j) to zero,
! as well as the corresponding q(m,i,j) for m=1,meqn.
! This is for problems where q(1,i,j) is a depth.
! This should occur only because of rounding error.
! 
! Also calls movetopo if topography might be moving.

    use geoclaw_module, only: dry_tolerance
    use geoclaw_module, only: g => grav
    use topo_module, only: num_dtopo,topotime
    use topo_module, only: aux_finalized
    use topo_module, only: xlowdtopo, xhidtopo, ylowdtopo, yhidtopo

    use amr_module, only: xlowdomain => xlower
    use amr_module, only: ylowdomain => ylower
    use amr_module, only: xhidomain => xupper
    use amr_module, only: yhidomain => yupper
    use amr_module, only: xperdom, yperdom, spheredom

    use storm_module, only: set_storm_fields
    
    implicit none
    
    ! Subroutine arguments
    integer, intent(in) :: mbc,mx,my,meqn,maux,mptr
    real(kind=8), intent(in) :: xlower, ylower, dx, dy, t, dt
    real(kind=8), intent(inout) :: q(meqn,1-mbc:mx+mbc,1-mbc:my+mbc)
    real(kind=8), intent(inout) :: aux(maux,1-mbc:mx+mbc,1-mbc:my+mbc)

    ! Local storage
    integer :: index, i, j, k
    real(kind=8) :: h, u, v

    ! Check for NaNs in the solution
    call check4nans(meqn,mbc,mx,my,q,t,1)

    ! check for h < 0 and reset to zero
    ! check for h < drytolerance
    ! set hu = hv = 0 in all these cells
    forall(i=1-mbc:mx+mbc, j=1-mbc:my+mbc,q(1,i,j) < dry_tolerance)
        q(1,i,j) = max(q(1,i,j),0.d0)
        q(2:3,i,j) = 0.d0
    end forall

    ! Move the topography if needed
    if (aux_finalized < 2) then
        ! topo arrays might have been updated by dtopo more recently than
        ! aux arrays were set unless at least 1 step taken on all levels
        call setaux(mbc,mx,my,xlower,ylower,dx,dy,maux,aux)
    endif


    ! Set wind and pressure aux variables for this grid
    if (t .lt. 300) then !otherwise leave ambient pressure in grids
    call   set_pressure_field(maux, mbc, mx, my, xlower, ylower, dx, dy, t, aux, mptr)
    endif

end subroutine b4step2
    
